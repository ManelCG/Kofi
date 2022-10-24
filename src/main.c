/*
 *  Kofi
 *  Copyright (C) 2022  Manel Castillo Giménez <manelcg@protonmail.com>
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <getopt.h>

#include <string.h>

#include <kofi_constants.h>
#include <kofi_parser.h>

void usage(const char *argv0){
  fprintf(stderr, "Usage: %s\n", argv0);

  exit(EXIT_FAILURE);
}

int main(int argc, char *argv[]){
  int opt;
  const char *arg;
  const char **menuitems;
  int flags = 0;

  while ((opt = getopt(argc, argv, "N")) != -1){
    switch(opt){
      case 'N':
        flags |= KOFI_EXPANDED_NEWLINES;
        break;
      case '?':
      default:
        usage(argv[0]);
        exit(EXIT_FAILURE);
    }
  }

  if (optind >= argc) {
    fprintf(stderr, "ERROR: Missing text argument\n");
    usage(argv[0]);
  }

  arg = argv[optind];
  if (strcmp(arg, "-") == 0){
    menuitems = (const char **) kofi_parser_text_to_list(NULL, stdin, flags);
  } else {
    menuitems = (const char **) kofi_parser_text_to_list(arg, NULL, flags);
  }

  if (menuitems != NULL){
    for (int i = 0; menuitems[i] != NULL; i++){
      printf("\"%s\"\n", menuitems[i]);
    }
  }

  exit(EXIT_SUCCESS);
}
