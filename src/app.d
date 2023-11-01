// █▄▄ █▀█ ▄▀█  █  █▀█ █▀▀ █ █ █▄▀ █▀▄
// █▄█ █▀▄ █▀█  █  █ █ █▀  █▄█ █ █ █▄▀
//
// A brainfuck interpreter in D with a handycap of -betterC
//
// Copyright (c) 2023, Alisa Lain (al1-ce / silyneko)

import core.stdc.stdio: printf, getc, perror, stdin;
import core.stdc.stdio: FILE, fopen, fread, fseek, ftell, rewind, fclose, SEEK_END;
import core.stdc.stdlib: exit, free, malloc, calloc;
import core.stdc.string: strlen;

// https://pubs.opengroup.org/onlinepubs/009695399/basedefs/errno.h.html
import core.stdc.errno: ENOENT, EINVAL, ENOMEM, EIO, EISDIR, ENODATA;

const int TAPE_SIZE = 32768; // 2^15

extern(C) int main(int argc, char** argv) {
    // printf("Edit source/app.d to start your project.");
    if (argc < 2) {
        perror("Please supply a single filepath");
        exit(EINVAL);
    }

    if (argv[1] == "--help" || argv[1] == "-h") {
        printf("Usage: brainfukd FILEPATH [INPUT?]\n\n" ~
               "Example:\nbrainfukd test.bf - executes test.bf" ~
               "\nbrainfukd xmas.bf 12 - execites xmas.bf and sets 12 as input");
    }

    FILE* fp;
    long lSize;
    char* buffer;
    char* filename = argv[1];

    char* bfArgs;
    ulong bfArgsIndex = 0;
    ulong bfArgsLen = 0;

    if (argc == 3) {
        bfArgs = argv[2];
        bfArgsLen = strlen(bfArgs);
    }

    fp = fopen(filename, "r");
    if (fp == null) {
        perror("Unable to open file");
        free(filename);
        exit(ENOENT);
    }

    // I like it being own block
    do {
        // For is directory
        import core.sys.posix.sys.stat: fstat, stat_t;
        import core.sys.posix.sys.types;
        import core.sys.posix.fcntl;
        import core.sys.posix.unistd;

        stat_t __buffer;
        int status;

        int filedes = open(filename, O_RDWR);
        status = fstat(filedes, &__buffer);

        if (status != 0) {
            perror("File is a directory");
            // free(filename);
            close(filedes);
            exit(EISDIR);
        }

        close(filedes);
    } while (false);

    // free(filename);

    fseek(fp, 0L, SEEK_END);
    lSize = ftell(fp);
    rewind(fp);

    buffer = cast(char*) calloc(1, lSize + 1);
    if (!buffer) {
        fclose(fp);
        perror("Memory allocation failed");
        exit(ENOMEM);
    }

    if (fread(buffer, lSize, 1, fp) != 1) {
        fclose(fp);
        free(buffer);
        perror("Failed to read file");
        exit(ENODATA);
    }

    byte[TAPE_SIZE] tape = 0; // maybe try `cent` type?
    int index = 0;

    for (int i = 0; i < lSize; ++i) {
        switch (buffer[i]) {
            case '<':
                ++index;
                if (index >= TAPE_SIZE) index = 0;
            break;
            case '>':
                --index;
                if (index < 0) index = TAPE_SIZE - 1;
            break;
            case '+':
                tape[index]++;
            break;
            case '-':
                tape[index]--;
            break;
            case '.':
                printf("%c", tape[index]);
            break;
            case ',':
                if (bfArgsLen && bfArgsIndex <= bfArgsLen) {
                    if (bfArgsIndex == bfArgsLen) {
                        tape[index] = '\0';
                    } else {
                        tape[index] = bfArgs[bfArgsIndex];
                    }
                    bfArgsIndex++;
                } else {
                    char c = cast(char) getc(stdin);
                    tape[index] = c;
                }
            break;
            case '[': // ]
                int bopen = 1;
                if (tape[index] == 0) {
                    while (i < lSize) {
                        ++i;
                        if (buffer[i] == '[') ++bopen;
                        if (buffer[i] == ']') {
                            if (bopen == 1) break;
                            --bopen;
                        }
                    }
                }
            break;
            // [
            case ']':
                int bclose = 1;
                if (tape[index] != 0) {
                    while (i >= 0) {
                        --i;
                        if (buffer[i] == '[') {
                            if (bclose == 1) break;
                            --bclose;
                        }
                        if (buffer[i] == ']') ++bclose;
                    }
                }
            break;
            default: break;
        }
    }

    fclose(fp);
    free(buffer);

    return 0;
}
