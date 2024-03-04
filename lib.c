#include "lib.h"

funcCmp_t *getCompareFunction(type_t t)
{
    switch (t)
    {
    case TypeInt:
        return (funcCmp_t *)&intCmp;
        break;
    case TypeString:
        return (funcCmp_t *)&strCmp;
        break;
    case TypeCard:
        return (funcCmp_t *)&cardCmp;
        break;
    default:
        break;
    }
    return 0;
}
funcClone_t *getCloneFunction(type_t t)
{
    switch (t)
    {
    case TypeInt:
        return (funcClone_t *)&intClone;
        break;
    case TypeString:
        return (funcClone_t *)&strClone;
        break;
    case TypeCard:
        return (funcClone_t *)&cardClone;
        break;
    default:
        break;
    }
    return 0;
}
funcDelete_t *getDeleteFunction(type_t t)
{
    switch (t)
    {
    case TypeInt:
        return (funcDelete_t *)&intDelete;
        break;
    case TypeString:
        return (funcDelete_t *)&strDelete;
        break;
    case TypeCard:
        return (funcDelete_t *)&cardDelete;
        break;
    default:
        break;
    }
    return 0;
}
funcPrint_t *getPrintFunction(type_t t)
{
    switch (t)
    {
    case TypeInt:
        return (funcPrint_t *)&intPrint;
        break;
    case TypeString:
        return (funcPrint_t *)&strPrint;
        break;
    case TypeCard:
        return (funcPrint_t *)&cardPrint;
        break;
    default:
        break;
    }
    return 0;
}

/** Int **/

int32_t intCmp(int32_t *a, int32_t *b)
{

    if (*a == *b)
    {
        return 0;
    }
    else if (*a < *b)
    {
        return 1;
    }
    else if (*a > *b)
    {
        return -1;
    }
}

void intDelete(int32_t *a)
{
    if (a != NULL)
    {
        free(a);
    }
}

void intPrint(int32_t *a, FILE *pFile)
{
    if ((a != NULL) && (pFile != NULL))
    {
        fprintf(pFile, "%d", *a);
    }
    else
    {
        fprintf(stdout, "Puntero nulo o archivo inválido.\n");
    }
}

int32_t *intClone(int32_t *a)
{
    if (a == NULL)
    {
        return NULL;
    }

    int32_t *clon = (int32_t *)malloc(sizeof(int32_t));

    if (clon != NULL)
    {
        memcpy(clon, a, sizeof(int32_t));
    }

    return clon;
}

/** Lista **/

list_t *listNew(type_t t)
{
    list_t *lista = malloc(sizeof(list_t));
    if (!lista)
        return NULL;
    lista->type = t;
    lista->size = 0;
    lista->first = NULL;
    lista->last = NULL;

    return lista;
}

uint8_t listGetSize(list_t *l)
{   if (!l || l == NULL) return 0;
    return l->size;
}

void *listGet(list_t *l, uint8_t i)
{
    if (i >= listGetSize(l))
        return 0;

    listElem_t *elemento_actual = l->first;
    size_t aux = 0;
    while (i != aux)
    {
        elemento_actual = elemento_actual->next;
        aux++;
    };

    return elemento_actual->data;
}

void listAddFirst(list_t *l, void *data)
{   
    listElem_t *nuevoElemento = (listElem_t *)malloc(sizeof(listElem_t));
    if (!nuevoElemento)
        return;

    funcClone_t *fclone = getCloneFunction(l->type);
    void *copiaData = fclone(data);

    nuevoElemento->data = copiaData;
    nuevoElemento->prev = NULL;

    if (listGetSize(l) != 0)
    {
        nuevoElemento->next = l->first;
        l->first->prev = nuevoElemento;
    }
    else
    {
        nuevoElemento->next = NULL;
        l->last = nuevoElemento;
    }

    l->first = nuevoElemento;
    l->size++;
}

void listAddLast(list_t *l, void *data)
{
    listElem_t *nuevoElemento = (listElem_t *)malloc(sizeof(listElem_t));
    if (!nuevoElemento)
        return;

    funcClone_t* fclone = getCloneFunction(l->type);
    void* copiaData = fclone(data);

    nuevoElemento->data = copiaData;
    nuevoElemento->next = NULL;

    if (listGetSize(l)!= 0)
    {
        l->last->next = nuevoElemento;
        nuevoElemento->prev = l->last;
    }
    else
    {
        nuevoElemento->prev = NULL;
        l->first = nuevoElemento;
    }

    l->last = nuevoElemento;
    l->size++;
}

void *iterate(list_t *l, uint8_t n)
{
    struct s_listElem *element = l->first;

    for (uint8_t i = 0; i <= n; i++)
    {
        element = element->next;
    }

    return element;
}

void *listRemove(list_t *l, uint8_t i)
{
    if (i >= listGetSize(l))
    {
        return 0;
    }

    // Caso de primer elemento en la lista donde prev = NULL
    if (i == 0)
    {
        listElem_t *elemento_actual = l->first;
        if (listGetSize(l) > 1)
        {
            elemento_actual->next->prev = NULL;
        }

        l->first = elemento_actual->next;
        void *dataElemento = elemento_actual->data;

        free(elemento_actual);
        l->size--;
        return dataElemento;
    }

    // Caso último elemento de la lista donde next = NULL
    if (i == listGetSize(l) - 1)
    {
        listElem_t *elemento_actual = l->last;
        elemento_actual->prev->next = NULL;
        l->last = elemento_actual->prev;
        void *dataElemento = elemento_actual->data;
        free(elemento_actual);
        l->size--;
        return dataElemento;
    }

    // Caso elemento en medio de la lista donde existen prev y next
    else
    {
        listElem_t *elemento_actual = l->first;
        uint8_t aux = 0;

        while (i != aux)
        {
            elemento_actual = elemento_actual->next;
            aux++;
        }

        listElem_t *prevElementoActual = elemento_actual->prev;
        listElem_t *nextElementoActual = elemento_actual->next;
        void *dataElemento = elemento_actual->data;
        prevElementoActual->next = nextElementoActual;
        nextElementoActual->prev = prevElementoActual;

        free(elemento_actual);
        l->size--;
        return dataElemento;
    }
}


void listSwap(list_t *l, uint8_t i, uint8_t j)
{
    if ((i > listGetSize(l)) || (j > listGetSize(l)) || (i == j))
        return;

    listElem_t *elemento_i = l->first;
    listElem_t *elemento_j = l->first;

    uint8_t aux = 0;
    while (aux != i && aux <= listGetSize(l))
    {
        elemento_i = elemento_i->next;
        aux++;
    }

    aux = 0;
    while (aux != j && aux <= listGetSize(l))
    {
        elemento_j = elemento_j->next;
        aux++;
    }

    void *dataElementoI = elemento_i->data;
    elemento_i->data = elemento_j->data;
    elemento_j->data = dataElementoI;
}

list_t *listClone(list_t *l)
{
    list_t *clonedList = listNew(l->type);
    uint8_t clonedListSize = 0;
    listElem_t *elementoActual = l->first;
    while (elementoActual)
    {
        listAddLast(clonedList, elementoActual->data);
        elementoActual = elementoActual->next;
        clonedListSize++;
    }
    clonedList->size = clonedListSize;
    return clonedList;
}

void listDelete(list_t *l){
    if (!l) return;
    struct s_listElem *elem = l->first;
    while (elem != NULL)
    {
        struct s_listElem *act = elem;
        elem = elem->next;

        switch (l->type)
        {
        case TypeCard:
            cardDelete(act->data);
            break;
        case TypeString:
            strDelete(act->data);
            break;
        case TypeInt:
            intDelete(act->data);
            break;
        default:
            return;
        }

        free(act);
    }
    free(l);
}

void listPrint(list_t *l, FILE *pFile)
{
    if (!l)
        return;
    listElem_t *firstActual = l->first;
    fprintf(pFile, "[");
    while (firstActual)
    {
        funcPrint_t *fprint = getPrintFunction(l->type);
        fprint(firstActual->data, pFile);
        firstActual = firstActual->next;
        if (firstActual)
        {
            fprintf(pFile, ",");
        }
    }
    fprintf(pFile, "]");
}

/** Game **/

game_t *gameNew(void *cardDeck, funcGet_t *funcGet, funcRemove_t *funcRemove, funcSize_t *funcSize, funcPrint_t *funcPrint, funcDelete_t *funcDelete)
{
    game_t *game = (game_t *)malloc(sizeof(game_t));
    game->cardDeck = cardDeck;
    game->funcGet = funcGet;
    game->funcRemove = funcRemove;
    game->funcSize = funcSize;
    game->funcPrint = funcPrint;
    game->funcDelete = funcDelete;
    return game;
}
int gamePlayStep(game_t *g)
{
    int applied = 0;
    uint8_t i = 0;
    while (applied == 0 && i + 2 < g->funcSize(g->cardDeck))
    {
        card_t *a = g->funcGet(g->cardDeck, i);
        card_t *b = g->funcGet(g->cardDeck, i + 1);
        card_t *c = g->funcGet(g->cardDeck, i + 2);
        if (strCmp(cardGetSuit(a), cardGetSuit(c)) == 0 || intCmp(cardGetNumber(a), cardGetNumber(c)) == 0)
        {
            card_t *removed = g->funcRemove(g->cardDeck, i);
            cardAddStacked(b, removed);
            cardDelete(removed);
            applied = 1;
        }
        i++;
    }
    return applied;
}
uint8_t gameGetCardDeckSize(game_t *g)
{
    return g->funcSize(g->cardDeck);
}
void gameDelete(game_t *g)
{
    g->funcDelete(g->cardDeck);
    free(g);
}
void gamePrint(game_t *g, FILE *pFile)
{
    g->funcPrint(g->cardDeck, pFile);
}
