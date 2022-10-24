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

#include <kofi_parser.h>
#include <kofi_constants.h>

#include <string.h>
#include <stdlib.h>

//  Either s or fd has to be NULL. If none or both are NULL, returns NULL
//  Chooses mode depending on which is NOT NULL
//  Flags tell function what options to do or not
char **kofi_parser_text_to_list(const char *s, FILE *fd, int flags){
  if (s == NULL && fd == NULL){
    return NULL;
  }
  if (!(s == NULL || fd == NULL)){
    return NULL;
  }

  int mode;
  if (s != NULL){
    mode = 's';
  } else {
    mode = 'f';
  }

  char **menuitems = malloc(sizeof(char *));

  int menuptr = 0;
  int strptr = 0;

  int defs = 16;
  int curs = defs;

  menuitems[0] = malloc(sizeof(char) * curs);
  int i = 0;
  char c;

  //Conjoined for(int i = 0; i < strlen(s); i++) and while(fread(&c, sizeof(c), 1, fd) in one statement.
  while ((mode == 's' && i < strlen(s)) || (mode == 'f' && fread(&c, sizeof(c), 1, fd))){
    if (mode == 's'){
      c = s[i];
    }
    switch(c){
      case '\\':
        if (mode == 's'){
          if (((flags & KOFI_EXPANDED_NEWLINES) == 0) || !(i < strlen(s) - 1 && s[i+1] == 'n')){
            goto appendchar;
            break;
          }
          i++;
        } else {  //File descriptor mode
          if ((flags & KOFI_EXPANDED_NEWLINES) != 0){
            char n = getc(fd);
            if (n != 'n'){
              ungetc(n, fd);
              goto appendchar;
              break;
            }
          } else {
            goto appendchar;
          }
        }
      case '\n':
        menuitems[menuptr][strptr] = '\0';
        menuptr++;
        strptr = 0;

        curs = defs;
        menuitems = realloc(menuitems, sizeof(char *) * (menuptr + 1));
        menuitems[menuptr] = malloc(sizeof(char) * defs);
        break;
      case '\0':
        menuitems[menuptr][strptr] = '\0';
        break;
      appendchar:
      default:
        menuitems[menuptr][strptr] = c;
        strptr++;
        if (strptr == curs){
          curs *= 2;
          menuitems[menuptr] = realloc(menuitems[menuptr], sizeof(char) * curs);
        }
        break;
    }
    i++;
  }

  switch(menuitems[menuptr][0]){
    case '\n':
    case '\0':
    case ' ':
      free(menuitems[menuptr]);
      menuitems[menuptr] = NULL;
      break;
    default:
      menuitems[menuptr][strptr] = '\0';
      menuptr++;
      menuitems = realloc(menuitems, sizeof(char *) * (menuptr + 1));
      menuitems[menuptr] = NULL;
  }

  return menuitems;
}
