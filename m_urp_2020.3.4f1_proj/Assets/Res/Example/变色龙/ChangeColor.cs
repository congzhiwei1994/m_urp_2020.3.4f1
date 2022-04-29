using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using System.IO;

public class ChangeColor : MonoBehaviour
{
    public Texture2D m_texGreen;
    public Texture2D m_texRed;
    public Texture2D m_texBlue;
    public Texture2D m_texYellow;
    [Range(0, 2)]
    public float m_speed = 0.0f;
    private Material m_material;

    float timeTotal = 0.0f;

    void Update()
    {
        if (timeTotal < 1)
        {
            timeTotal += Time.deltaTime * m_speed;
            m_material.SetFloat("_Speed", timeTotal);
        }
    }

    [ContextMenu("Test")]
    public void Set()
    {
        SetColor(m_texRed, m_texBlue);
    }

    public void SetColor(Texture2D texNew, Texture2D texOld)
    {
        var renderer = this.GetComponent<Renderer>();
        m_material = renderer.sharedMaterial;
        if (m_material == null)
        {
            return;
        }

        m_material.SetTexture("_BaseMap_Old", texOld);
        m_material.SetTexture("_BaseMap_New", texNew);

        timeTotal = 0.0f;

    }

}
