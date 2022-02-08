using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public delegate int MyDelegate(int temp);
[ExecuteInEditMode]
public class Test : MonoBehaviour
{
    MyDelegate m_delegate1;
    void Start()
    {
        m_delegate1 = Func01;
        m_delegate1(2);
    }
    public int Func01(int a)
    {
        Debug.LogError("Func01");
        return a;
    }

}

