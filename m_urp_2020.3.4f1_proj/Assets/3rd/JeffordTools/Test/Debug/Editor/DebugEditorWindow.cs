using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;
using Jefford.Csharp;
using System;


public class DebugEditorWindow : EditorWindow
{
    private GameObject m_gameObject;

    [MenuItem("Jefford/DebugEditorWindow")]
    private static void Open()
    {
        var window = GetWindow<DebugEditorWindow>("DebugEditorWindow");
        window.Show();
    }

    private void OnEnable()
    {

    }

    private void OnGUI()
    {
        if (GUILayout.Button("测试"))
        {
            m_gameObject.Rename("New Name");
        }

    }
}

public static class MyGameObject
{
    public static void Rename(this GameObject go, string newName)
    {
        go.name = newName;
    }
}
