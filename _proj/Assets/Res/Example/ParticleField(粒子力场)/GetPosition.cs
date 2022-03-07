using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class GetPosition : MonoBehaviour
{
    public Material m_matetial;
    public GameObject m_go;
    void Start()
    {

    }


    void Update()
    {
        if (m_go != null && m_matetial != null)
        {
            m_matetial.SetVector("_Position", m_go.transform.position);
        }


    }
}
