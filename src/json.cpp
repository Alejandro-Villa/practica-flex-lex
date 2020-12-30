#include "json.h"
#include <cstring>

using namespace std;

void* assingData(value_t jsonType, size_t dataSize, void* jsonData) {
    void* data = NULL;
    switch (jsonType) {
        case str:
            data = calloc(dataSize, sizeof(char));  //new char[size];
            strcpy((char*)data, (char*)jsonData);
            break;
        case num:
            data = malloc(sizeof(long double)); //new long double;
            *(long double*)data = *(long double*)jsonData;
            break;
        case obj:
            /* TODO */
            break;
        case arr:
            /* TODO */
            break;
        case tru:
            data = malloc(sizeof(bool)); //new bool;
            *(bool*)data = true;
            break;
        case fal:
            data = malloc(sizeof(bool)); //new bool;
            *(bool*)data = false;
            break;
        case nil:
            data = NULL;
            break;
        default:
            cerr << "ERR:JSONValue(): Tipo de Valor no reconocido" << endl;
            exit(1);
    }
    return data;
}

JSONValue::JSONValue(value_t jsonType, size_t dataSize, void* jsonData) {
    type = jsonType;
    size = dataSize;
    data = assingData(type, size, jsonData);
}

JSONValue::JSONValue(const JSONValue& orig) {
    type = orig.type;
    size = orig.size;
    data = assingData(type, size, orig.data);
}

JSONValue::~JSONValue() {
    if(data != NULL) free(data);
    data = NULL;
    /*
    switch (type) {
        case str: break;
        case num: break;
        case obj:
            break;
        case arr:
            break;
        case tru:
        case fal:
        case nil:
                  delete (bool*)data; break;
    }
    */
}

void JSONValue::printData(FILE* out) {
    switch (type) {
        case str: 
            fprintf(out, "\"%s\"", static_cast<string*>(data)->c_str()); break;
        case num:
            fprintf(out, "\"%Lg\"", *(long double*)data); break;
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

void JSONObject::add_pair(const std::pair<std::string, JSONValue>& data) {
    contents.push_back(data);
}
