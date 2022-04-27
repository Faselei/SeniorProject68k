/* LinkedList.c */

//By: Julian Zelazny

/*
Linked List implementation, this is frankly too late to be of much use,
but its better for it to be late then never
*/

#include <linkedList.h>

typedef struct node_s { //define what node_s is
        node_t* prev;
        void* data;
        uint16_t size;
        node_t* next;
}node_s;

typedef struct linkedList_s {
        node_t* head;
        uint16_t size;
        node_t* tail;
}linkedList_s;

/* create a new linkedList type on the heap*/
linkedList_t* createNewLinkedList(void){

    linkedList_t* newLinkedList;

//make a new linked list list thing on the heap
    newLinkedList = malloc(sizeof(linkedList_t));

//make sure that we are not about to cause access violations
        if (newLinkedList) //if not null
            memset(newLinkedList, 0, sizeof(linkedList_t)); //clear its memory

    return newLinkedList;
}

/* insert data into linked list */
node_t* insertInLinkedList(linkedList_t* thisLinkedList, void* data, uint16_t size){

    node_t* node;
    void* nodeData;

    //make sure that the input is valid
    if (thisLinkedList && data){ //make sure that neither of these are NULL (0)

        //allocate a node on the heap and start filling out the struct
        node = malloc(sizeof(node_t));
        nodeData = malloc(size);
        memcpy(nodeData, data, size);
        node->data = nodeData;
        node->size = size;
        node->next = NULL;
        thisLinkedList->size++;

        //if there is no tail, then we assume that there is no head as well
        if(!thisLinkedList->tail)
                thisLinkedList->head = node;

        //in any case we link this to the tail of the linked list
        node->prev = thisLinkedList->tail;      //can be null
        thisLinkedList->tail = node;

    }

    return node;
}

/* delete a node from the linked list */
void removeNodeInLinkedList(linkedList_t* thisLinkedList, node_t* thisElement){
        node_t* tempNode;

//step through each element in the linked list untill we find the node we want
//or we reach the end without finding it
        tempNode = thisLinkedList->head;

        while(tempNode){ //keep going untill we have a null pointer

                //is this the node we want?
                if (tempNode == thisElement){

                        //delete everything, link around, and free the node
                        free(tempNode->data);

                        if(tempNode->prev) //make sure there is a prev
                                tempNode->prev->next = tempNode->next;

                        if(tempNode->next) //make sure there is a next
                                tempNode->next->prev = tempNode->prev;

                        free(tempNode);

                        tempNode = NULL;
                } else
                        tempNode = tempNode->next;
        }
}
