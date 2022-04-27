/* linkedList.h */

#ifndef LINKEDLIST_H
#define LINKEDLIST_H

//dependencies
#include <stdint.h>
#include <DynamicMemory.h>
#include <string.h>

//opaque type

/* I know that this typedefing abstract types are NOT C complient
 but VASM won't shut up on warning and errors unless I do it this way.
-Julian
*/
typedef struct linkedList_s linkedList_t;
typedef struct node_s node_t;

//function prototypes
linkedList_t* createNewLinkedList(void);
node_t* insertInLinkedList(linkedList_t* thisLinkedList, void* data, uint16_t size);
void removeNodeInLinkedList(linkedList_t* thisLinkedList, node_t* thisElement);

#endif //LINKEDLIST_H
