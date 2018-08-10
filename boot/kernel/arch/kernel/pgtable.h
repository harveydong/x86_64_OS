#ifndef __PGTABLE_H_
#define __PGTABLE_H_
#include "page_64_types.h"
 



#define _PAGE_BIT_PRESENT 0
#define _PAGE_BIT_RW 1
#define _PAGE_BIT_USER 2
#define _PAGE_BIT_ACCESSED 5
#define _PAGE_BIT_DIRTY 6
#define _PAGE_BIT_PSE 7
#define _PAGE_BIT_GLOBAL 8

#define _PAGE_PRESENT (1 << _PAGE_BIT_PRESENT)
#define _PAGE_RW (1 << _PAGE_BIT_RW)
#define _PAGE_ACCESSED (1 << _PAGE_BIT_ACCESSED)
#define _PAGE_DIRTY (1 << _PAGE_BIT_DIRTY)
#define _PAGE_PSE (1 << _PAGE_BIT_PSE)
#define _PAGE_GLOBAL (1 << _PAGE_BIT_GLOBAL)
#define _KERNEL_TABLE (_PAGE_PRESENT|_PAGE_RW|_PAGE_ACCESSED|_PAGE_DIRTY)
#define _PAGE_USER	(1 << _PAGE_BIT_USER)



#define __PAGE_KERNEL_EXEC (_PAGE_PRESENT|_PAGE_RW|_PAGE_DIRTY|_PAGE_ACCESSED|_PAGE_GLOBAL)

#define __PAGE_KERNEL_LARGE_EXEC (__PAGE_KERNEL_EXEC|_PAGE_PSE)
#define __PAGE_KERNEL_IDENT_LARGE_EXEC __PAGE_KERNEL_LARGE_EXEC

#define _KERNPG_TABLE (_PAGE_PRESENT|_PAGE_RW|_PAGE_ACCESSED|_PAGE_DIRTY)
#define _PAGE_TABLE (_PAGE_PRESENT|_PAGE_RW|_PAGE_USER|_PAGE_ACCESSED|_PAGE_DIRTY)
#endif