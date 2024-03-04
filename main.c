#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>
#include <math.h>

#include "lib.h"

void pruebasEnunciadoConLista(){
    /*
    Crear un mazo con 5 cartas sobre una lista
    Imprimir el mazo.
    Apilar una carta cualquiera del mazo sobre otra carta cualquiera.
    Imprimir nuevamente el mazo.
    Borrar el mazo.
    */

    int32_t numero1 = 1;
    int32_t* puntero1 = &numero1;
    int32_t numero7 = 7;
    int32_t* puntero7 = &numero7;
    int32_t numero5= 5;
    int32_t* puntero5 = &numero5;

    char espada[] = "Espada";
    char basto[] = "Basto";
    char copa[] = "Copa";
    char oro[] = "Oro";

    card_t* anchoDeBasto = cardNew(basto, puntero1);
    card_t* anchoDeEspadas = cardNew(espada, puntero1);
    card_t* sieteDeOro = cardNew(oro, puntero7);
    card_t* sieteDeEspadas = cardNew(espada, puntero7);
    card_t* cincoDeCopas = cardNew(copa, puntero5);
    card_t* otroSieteDeOro = cardNew(oro, puntero7);

    list_t* nuevaLista = listNew(TypeCard);
    listAddLast(nuevaLista, anchoDeEspadas);
    listAddLast(nuevaLista, anchoDeBasto);
    listAddLast(nuevaLista, sieteDeEspadas);
    listAddLast(nuevaLista, sieteDeOro);
    listAddLast(nuevaLista, cincoDeCopas);
    
    FILE* archivo = fopen("output.txt", "w");
    listPrint(nuevaLista, archivo);
    fclose(archivo);
    
    uint8_t listSize = listGetSize(nuevaLista);
    card_t* cincoDeCopasSacadoDelMazo = listRemove(nuevaLista, (uint8_t)listSize-1);
    cardAddStacked(otroSieteDeOro, cincoDeCopasSacadoDelMazo);
    listAddLast(nuevaLista, otroSieteDeOro);

    FILE* archivo2 = fopen("output2.txt", "w");
    listPrint(nuevaLista, archivo2);
    fclose(archivo2);

    cardDelete(otroSieteDeOro);
    cardDelete(cincoDeCopasSacadoDelMazo);
    cardDelete(sieteDeEspadas);
    cardDelete(cincoDeCopas);
    cardDelete(anchoDeBasto);
    cardDelete(anchoDeEspadas);
    cardDelete(sieteDeOro);

    listDelete(nuevaLista);
    printf("Pruebas de enunciado con Cartas con lista TODO OK, revisar archivos\n");
}

void pruebasEnunciadoConArray(){
    /*
    Crear un mazo con 5 cartas sobre un arreglo
    Imprimir el mazo.
    Apilar una carta cualquiera del mazo sobre otra carta cualquiera.
    Imprimir nuevamente el mazo.
    Borrar el mazo.
    */
    int32_t numero1 = 1;
    int32_t* puntero1 = &numero1;
    int32_t numero7 = 7;
    int32_t* puntero7 = &numero7;
    int32_t numero5= 5;
    int32_t* puntero5 = &numero5;

    char espada[] = "Espada";
    char basto[] = "Basto";
    char copa[] = "Copa";
    char oro[] = "Oro";

    card_t* anchoDeBasto = cardNew(basto, puntero1);
    card_t* anchoDeEspadas = cardNew(espada, puntero1);
    card_t* sieteDeOro = cardNew(oro, puntero7);
    card_t* sieteDeEspadas = cardNew(espada, puntero7);
    card_t* cincoDeCopas = cardNew(copa, puntero5);
    card_t* otroAnchoDeEspadas = cardNew(espada, puntero1);
    
    uint8_t tamañoArreglo = 5;
    array_t* nuevoArreglo = arrayNew(TypeCard, tamañoArreglo);
    arrayAddLast(nuevoArreglo, sieteDeEspadas);
    arrayAddLast(nuevoArreglo, cincoDeCopas);
    arrayAddLast(nuevoArreglo, anchoDeEspadas);
    arrayAddLast(nuevoArreglo, anchoDeBasto);
    arrayAddLast(nuevoArreglo, sieteDeOro);
    
    FILE* archivo3 = fopen("output3.txt", "w");
    arrayPrint(nuevoArreglo, archivo3);
    fclose(archivo3);

    uint8_t arraySize = arrayGetSize(nuevoArreglo);
    card_t* sieteDeOroSacadoDelMazo = arrayRemove(nuevoArreglo, (uint8_t)arraySize-1);
    cardAddStacked(otroAnchoDeEspadas, sieteDeOroSacadoDelMazo);
    arrayAddLast(nuevoArreglo, otroAnchoDeEspadas);
    
    FILE* archivo4 = fopen("output4.txt", "w");
    arrayPrint(nuevoArreglo, archivo4);
    fclose(archivo4);    
  
    cardDelete(otroAnchoDeEspadas);
    cardDelete(sieteDeOroSacadoDelMazo);
    cardDelete(sieteDeEspadas);
    cardDelete(cincoDeCopas);
    cardDelete(anchoDeBasto);
    cardDelete(anchoDeEspadas);
    cardDelete(sieteDeOro);
    arrayDelete(nuevoArreglo);

    printf("Pruebas de enunciado con Cartas con arreglo TODO OK, revisar archivos\n");
}

int main (void){    
    pruebasEnunciadoConLista();
    pruebasEnunciadoConArray();
    return 0;
}
