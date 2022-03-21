using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class GetPosition : MonoBehaviour
{
    public Material m_matetial;
    public GameObject m_go;
    public string m_matName;
    void Start()
    {

    }


    void Update()
    {
        if (m_go != null && m_matetial != null && !string.IsNullOrEmpty(m_matName))
        {
            m_matetial.SetVector(m_matName, m_go.transform.position);
        }


    }
}
