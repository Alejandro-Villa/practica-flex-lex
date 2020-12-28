#include "json.h"

using namespace std;

JSONValue::JSONValue(value_t jsonType, size_t dataSize, void* jsonData) {
    type = jsonType;
    switch (type) {
        case str:
            data = new string[jsonData->size()];
            if(copy(data, jsonData->size()) != jsonData->size())
               cerr << "ERR:JSONValue(): No se han copiado todos los caracteres" << endl;
            size = data.size();
            break;
        case num:
            data = new long double;
            *data = *jsonData;
            break;
        case obj:
            /* TODO */
            break;
        case arr:
            /* TODO */
            break;
        case tru:
            data = new bool;
            *data = true;
            break;
        case fal:
            data = new bool;
            *data = false;
            break;
        case nil:
            data = NULL;
            break;
        case default:
            cerr << "ERR:JSONValue(): Tipo de Valor no reconocido" << endl;
            exit(1);
    }
}

JSONValue::~JSONValue() {
    switch (type) {
        case str: delete[] (*string) data; break;
        case num: delete (*long double) data; break;
        case obj:
            /* TODO */
            break;
        case arr:
            /* TODO */
            break;
        case tru:
        case fal:
        case nil:
                  delete (*bool) data; break;
    }
}
