/* Native ABI adapter for Factor. All filesystem policy lives in Factor. */
#define _FILE_OFFSET_BITS 64
#ifdef __APPLE__
#define _DARWIN_USE_64_BIT_INODE 1
#endif
#ifndef FUSE_USE_VERSION
#define FUSE_USE_VERSION 31
#endif
#include <fuse.h>
#include <errno.h>
#include <limits.h>
#include <stdint.h>
#include <string.h>
#include <unistd.h>

typedef int (*factor_dispatch)(int, const char *, void *, size_t, int64_t);
struct factor_fs { factor_dispatch dispatch; };
struct factor_directory { void *buffer; fuse_fill_dir_t fill; };

static int dispatch(int op, const char *path, void *buf, size_t size, off_t off)
{
    struct factor_fs *fs = fuse_get_context()->private_data;
    return fs->dispatch(op, path, buf, size, (int64_t)off);
}

void factor_fuse_stat(void *buffer, int directory, int64_t size)
{
    struct stat *st = buffer;
    memset(st, 0, sizeof(*st));
    st->st_mode = directory ? (S_IFDIR | 0555) : (S_IFREG | 0444);
    st->st_nlink = directory ? 2 : 1;
    st->st_uid = getuid();
    st->st_gid = getgid();
    st->st_size = size;
    st->st_blksize = 4096;
}

int factor_fuse_add_entry(void *buffer, const char *name, int64_t next)
{
    struct factor_directory *dir = buffer;
#if FUSE_USE_VERSION >= 30
    return dir->fill(dir->buffer, name, NULL, (off_t)next, 0);
#else
    return dir->fill(dir->buffer, name, NULL, (off_t)next);
#endif
}

static int fs_getattr(const char *path, struct stat *st
#if FUSE_USE_VERSION >= 30
                      , struct fuse_file_info *fi
#endif
)
{
#if FUSE_USE_VERSION >= 30
    (void)fi;
#endif
    return dispatch(0, path, st, 0, 0);
}

static int fs_readdir(const char *path, void *buf, fuse_fill_dir_t fill,
                      off_t offset, struct fuse_file_info *fi
#if FUSE_USE_VERSION >= 30
                      , enum fuse_readdir_flags flags
#endif
)
{
    (void)fi;
#if FUSE_USE_VERSION >= 30
    (void)flags;
#endif
    if (offset < 0) return -EINVAL;
    struct factor_directory dir = { buf, fill };
    return dispatch(1, path, &dir, 0, offset);
}

static int fs_open(const char *path, struct fuse_file_info *fi)
{
    if ((fi->flags & O_ACCMODE) != O_RDONLY ||
        (fi->flags & (O_TRUNC | O_APPEND))) return -EROFS;
    return dispatch(2, path, NULL, 0, 0);
}

static int fs_read(const char *path, char *buf, size_t size, off_t offset,
                   struct fuse_file_info *fi)
{
    (void)fi;
    if (offset < 0) return -EINVAL;
    if (size > INT_MAX) size = INT_MAX;
    return dispatch(3, path, buf, size, offset);
}

int factor_fuse_main(const char *mountpoint, factor_dispatch callback)
{
    if (!mountpoint || mountpoint[0] != '/') return -EINVAL;
    /* No daemonization or worker threads; ro rejects all mutations. */
    char *argv[] = { "factor-fuse", "-f", "-s", "-o",
                     "ro,default_permissions", (char *)mountpoint, NULL };
    struct factor_fs fs = { callback };
    const struct fuse_operations ops = {
        .getattr = fs_getattr,
        .readdir = fs_readdir,
        .open = fs_open,
        .read = fs_read
    };
    return fuse_main(6, argv, &ops, &fs);
}
