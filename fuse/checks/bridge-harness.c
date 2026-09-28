/* Run the real bridge and Factor callbacks without a kernel mount.
 * Replaces only libfuse's entry point/context; uses official native headers.
 * The Factor caller must supply a help-fs containing kernel and math. */
#define _FILE_OFFSET_BITS 64
#ifdef __APPLE__
#define _DARWIN_USE_64_BIT_INODE 1
#endif
#ifndef FUSE_USE_VERSION
#define FUSE_USE_VERSION 31
#endif
#include <fuse.h>

/* Intercept the public entry point, independent of libfuse's internal
 * fuse_main_real vs fuse_main_real_versioned implementation. */
static int test_fuse_main(int, char **, const struct fuse_operations *,
                          size_t, void *);
#undef fuse_main
#define fuse_main(argc, argv, op, data) \
    test_fuse_main(argc, argv, op, sizeof(*(op)), data)
#include "../bridge.c"
#include <assert.h>
#include <stdlib.h>

static struct fuse_context test_context;
struct fuse_context *fuse_get_context(void) { return &test_context; }

struct listing { int count; off_t next; char name[256]; };
static int fill_one(void *buffer, const char *name, const struct stat *st,
                    off_t next
#if FUSE_USE_VERSION >= 30
                    , enum fuse_fill_dir_flags flags
#endif
)
{
    (void)st;
#if FUSE_USE_VERSION >= 30
    (void)flags;
#endif
    struct listing *list = buffer;
    if (list->count) return 1;
    list->count++;
    list->next = next;
    assert(strlen(name) < sizeof(list->name));
    strcpy(list->name, name);
    return 0;
}

static int test_fuse_main(int argc, char **argv, const struct fuse_operations *op,
                   size_t size, void *data)
{
    assert(argc == 6 && size == sizeof(*op));
    assert(!strcmp(argv[1], "-f") && !strcmp(argv[2], "-s"));
    assert(!strcmp(argv[4], "ro,default_permissions"));
    test_context.private_data = data;
    struct stat st;
    struct fuse_file_info fi = {0};
#if FUSE_USE_VERSION >= 30
#define GETATTR(path) op->getattr(path, &st, NULL)
#define READDIR(path, list, off) op->readdir(path, list, fill_one, off, &fi, 0)
#else
#define GETATTR(path) op->getattr(path, &st)
#define READDIR(path, list, off) op->readdir(path, list, fill_one, off, &fi)
#endif
    assert(GETATTR("/") == 0 && S_ISDIR(st.st_mode));
    assert((st.st_mode & 0777) == 0555);
    assert(GETATTR("/kernel/dup") == 0 && S_ISREG(st.st_mode));
    assert((st.st_mode & 0777) == 0444 && st.st_size > 0);
    size_t length = (size_t)st.st_size;
    char *bytes = calloc(length + 1, 1);
    assert(bytes);
    assert(op->open("/kernel/dup", &fi) == 0);
    assert(op->read("/kernel/dup", bytes, length, 0, &fi) == (int)length);
    assert(strstr(bytes, "Word description") && strstr(bytes, "dup"));
    char partial[7];
    assert(op->read("/kernel/dup", partial, sizeof(partial), 3, &fi) == 7);
    assert(!memcmp(partial, bytes + 3, 7));
    assert(op->read("/kernel/dup", partial, 7, length, &fi) == 0);
    assert(op->read("/kernel/dup", partial, 7, -1, &fi) == -EINVAL);
    assert(op->read("/kernel", partial, 7, 0, &fi) == -EISDIR);
    assert(op->open("/kernel", &fi) == -EISDIR);
    assert(GETATTR("/missing") == -ENOENT);
    fi.flags = O_WRONLY;
    assert(op->open("/kernel/dup", &fi) == -EROFS);
    fi.flags = O_RDONLY | O_TRUNC;
    assert(op->open("/kernel/dup", &fi) == -EROFS);
    fi.flags = O_RDONLY;
    const char *expected[] = { ".", "..", "kernel", "math" };
    off_t offset = 0;
    for (int i = 0; i < 4; i++) {
        struct listing list = {0};
        assert(READDIR("/", &list, offset) == 0);
        assert(list.count == 1 && !strcmp(list.name, expected[i]));
        assert(list.next == offset + 1);
        offset = list.next;
    }
    struct listing list = {0};
    assert(READDIR("/", &list, offset) == 0 && list.count == 0);
    assert(READDIR("/kernel/dup", &list, 0) == -ENOTDIR);
    free(bytes);
    return 0;
}
