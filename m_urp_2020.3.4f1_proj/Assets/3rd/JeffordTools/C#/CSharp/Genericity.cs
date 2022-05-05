
// 泛型
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Jefford.Csharp
{
    // 定义一个泛型类
    public class Genericity<T>
    {
        // 定义泛型字段
        private T a;
        private T b;

        public Genericity(T a, T b)
        {
            this.a = a;
            this.b = b;
        }

        public string GetSum()
        {
            Debug.LogError(a + "" + b);
            return a + "" + b;
        }
    }

}
