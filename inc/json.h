#ifndef JSON_H
#define JSON_H

#include <iostream>// istream ostream
#include <vector>  // vector
#include <utility> // pair
#include <string>  // string

/* Enum que define los posibles valores de un valor de JSON */
enum value_json {
    str,
    num,
    obj,
    arr,
    tru,
    fal,
    nil
}; 

typedef value_json value_t;

/* Clases para ayudar en el manejo de información estilo JSON */
class JSONValue {
    private:
       value_t type;
       size_t size;
       void* data;
    public:
       JSONValue(value_t jsonType, size_t dataSize, void* jsonData);
       JSONValue(const JSONValue& orig);
       ~JSONValue(); 
       inline value_t getType() {return type;}
       void printData(FILE* out = stdout);
       friend std::ostream &operator<<(std::ostream &out, const JSONValue& value);
       friend std::istream &operator>>(std::istream &in, JSONValue& value);
};

class JSONArray {
    private:
        std::vector<JSONValue> data;
};

class JSONObject {
    private:
        std::vector<std::pair<std::string, JSONValue>> contents;
    public:
        void add_pair(const std::pair<std::string, JSONValue>& data);
        void printData(FILE* out = stdout);
        friend std::ostream &operator<<(std::ostream &out, const JSONObject& obj);
};

#endif
