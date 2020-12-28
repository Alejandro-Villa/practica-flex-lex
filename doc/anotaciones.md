Ideas para que esto funcione:

- Crear clases en c++ que guarden un objeto JSON y que además sean recursivas. 
```cpp
enum value_t {
    str,
    num,
    obj,
    arr,
    tru
    fal,
    nil
} value_type;

class Value {
    private const value_type type;
    private void* data;
}
```

Para la clase Value vamos a necesitar un constructor que tome como parámetro el tipo de dato y un puntero al dato en sí, entonces reservamos la memoria suficiente y copiamos el dato del puntero a nuestra memoria de la clase. Cuidado que hay que borrar si o si la memoria cuando acabemos en el destructor.

```cpp
class Object {
    vector<pair<string, Value> contents;
}
```

```cpp
class Array {
    private vector<Value> data;
}
```

Para la clase Array simplemente guardamos un vector de valores. La STL debería ayudarnos aquí y deberíamos tener memoria dinámica.
