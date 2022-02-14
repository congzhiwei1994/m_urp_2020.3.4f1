using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public delegate void MyDelegate();
public class Test : MonoBehaviour
{
    MyDelegate m_delegate1;
    void Start()
    {
        m_delegate1 = Test1;
        m_delegate1();
    }

    public void Test1()
    {
        Debug.LogError("Test1");
    }

}

