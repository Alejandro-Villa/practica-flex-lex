#include "json.h"

using namespace std;

JSONValue::JSONValue(value_t jsonType, size_t dataSize, void* jsonData) {
    type = jsonType;
    switch (type) {
        case str:
            size = dataSize;
            data = new string[size];
            if(static_cast<string*>(jsonData)->copy((char*)data, size, 0) != size)
               cerr << "ERR:JSONValue(): No se han copiado todos los caracteres" << endl;
            break;
        case num:
            data = new long double;
            *(long double*)data = *(long double*)jsonData;
            break;
        case obj:
            /* TODO */
            break;
        case arr:
            /* TODO */
            break;
        case tru:
            data = new bool;
            *(bool*)data = true;
            break;
        case fal:
            data = new bool;
            *(bool*)data = false;
            break;
        case nil:
            data = NULL;
            break;
        default:
            cerr << "ERR:JSONValue(): Tipo de Valor no reconocido" << endl;
            exit(1);
    }
}

JSONValue::~JSONValue() {
    switch (type) {
        case str: delete[] (string*) data; break;
        case num: delete (long double*) data; break;
        case obj:
            /* TODO */
            break;
        case arr:
            /* TODO */
            break;
        case tru:
        case fal:
        case nil:
                  delete (bool*)data; break;
    }
}

void JSONValue::printData(FILE* out) {
    switch (type) {
        case str: 
            fprintf(out, "\"%s\"", (string*)data); break;
        case num:
            fprintf(out, "\"%g\"", (long double*)data); break;
        case obj:
            /* TODO */
            break;
        case arr:
            /* TODO */
            break;
        case tru:
            fprintf(out, "\"true\""); break;
        case fal:
            fprintf(out, "\"false\""); break;
        case nil:
            fprintf(out, "\"nil\""); break;
    }
}
