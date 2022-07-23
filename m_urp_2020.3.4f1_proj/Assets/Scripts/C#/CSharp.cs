using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;


namespace Jefford.Csharp
{
    public class CSharp : MonoBehaviour
    {
        public float _float = 1;

        public void Start()
        {
        }

        public void OnValidate()
        {
            Debug.LogError(_float);
        }

        [ContextMenu("测试")]
        public void Test()
        {
        }
    }
}