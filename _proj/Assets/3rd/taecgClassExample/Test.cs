using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public delegate int MyDelegate(int a);
public class Test : MonoBehaviour
{
    MyDelegate m_delegate1;
    void Start()
    {
        m_delegate1 = a => a;

    }

}

