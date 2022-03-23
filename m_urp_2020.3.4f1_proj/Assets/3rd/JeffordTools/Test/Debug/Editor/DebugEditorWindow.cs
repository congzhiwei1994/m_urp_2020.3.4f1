using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;
using Jefford.Csharp;

public class DebugEditorWindow : EditorWindow
{
    Delegate01 m_del01;
    [MenuItem("Jefford/DebugEditorWindow")]
    private static void Open()
    {
        var window = GetWindow<DebugEditorWindow>("DebugEditorWindow");
        window.Show();
    }

    private void OnEnable()
    {

        m_del01 = delegate (int value)
        {
            return value;
        };

        //Lambda表达式
        m_del01 = (int value) =>
        {
            return value;
        };

        // 没有参数的话要有双括号
        m_del01 = (value) =>
        {
            return value;
        };

        // 如果只有一个参数的话
        m_del01 = value =>
        {
            return value;
        };

        // 如果只返回一条语句的话
        m_del01 = value => value;



    }

    private void OnGUI()
    {

        if (GUILayout.Button("测试"))
        {
            if (m_del01 != null)
            {
                m_del01(5);
            }
        }

    }
}
