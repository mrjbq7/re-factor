package main

import (
	"crypto/md5"
	"flag"
	"fmt"
	"io/ioutil"
	"os"
	"path"
	"path/filepath"
)

var verbose *bool = flag.Bool("verbose", false, "Print the list of duplicate files.")
var rootDir string = "."
var fullPathsByFilename map[string][]string

func VisitFile(fullpath string, f os.FileInfo, err error) error {
    if err != nil {
        return err
    }
    if !f.IsDir() {
        filename := path.Base(fullpath)
        fullPathsByFilename[filename] = append(fullPathsByFilename[filename], fullpath)
    }
    return nil;
}

func MD5OfFile(fullpath string) []byte {
	if contents, err := ioutil.ReadFile(fullpath); err == nil {
		md5sum := md5.New()
		md5sum.Write(contents)
		return md5sum.Sum(nil)
	}
	return nil
}

func PrintResults() {
	dupes := 0
	for key, value := range fullPathsByFilename {
		if len(value) < 2 {
			continue
		}
		dupes++
		if *verbose {
			println(key, ":")
			for _, filename := range value {
				println("  ", filename)
				fmt.Printf("    %x\n", MD5OfFile(filename))
			}
		}
	}
	println("Total duped files found:", dupes)
}

func FindDupes(root string) {
	fullPathsByFilename = make(map[string][]string)
	filepath.Walk(root, VisitFile)
}

func ParseArgs() {
	flag.Parse()
	if len(flag.Args()) > 0 {
		rootDir = flag.Arg(0)
	}
}

func main() {
	ParseArgs()
	FindDupes(rootDir)
	PrintResults()
}
