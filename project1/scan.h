
#ifndef _SCAN_H_
#define _SCAN_H_

#include "globals.h"

#define MAXTOKENLEN 40

extern char token_string[MAXTOKENLEN + 1];

token_t next_token(void);

#endif
