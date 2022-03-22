using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;
using Jefford.Csharp;

public class DebugEditorWindow : EditorWindow
{
    MyDelegateClass m_myClass;
    M_Delegate m_Delegate;
    IntDelegate m_intDel;
    RefDelegate m_refDel;

    [MenuItem("Jefford/DebugEditorWindow")]
    private static void Open()
    {
        var window = GetWindow<DebugEditorWindow>("DebugEditorWindow");
        window.Show();
    }

    private void OnEnable()
    {
        m_myClass = new MyDelegateClass();
        // void 类型
        m_Delegate = m_myClass.DelegateFun01;
        m_Delegate += m_myClass.DelegateFun02;

        // Int 类型
        m_intDel = m_myClass.DelIntFun01;
        m_intDel += m_myClass.DelIntFun02;
        m_intDel += MyDelegateClass.DelIntFun03;

        // ref
        m_refDel = m_myClass.RefDelFun01;
    }

    private void OnGUI()
    {

        if (GUILayout.Button("测试"))
        {
            if (m_refDel != null)
            {
                int value = 5;
                m_refDel(ref value);
            }
        }

    }
}
