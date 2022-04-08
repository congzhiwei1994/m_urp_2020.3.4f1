using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;
using Jefford.Csharp;
using System;

public enum Test
{
    测试1,
    测试2,
    测试3
}


public class DebugEditorWindow : EditorWindow
{
    HashSet<Test> m_hash = new HashSet<Test>();
    Dictionary<Test, int> m_Dic = new Dictionary<Test, int>();


    [MenuItem("Jefford/DebugEditorWindow &q")]
    private static void Open()
    {
        var window = GetWindow<DebugEditorWindow>("DebugEditorWindow");
        window.Show();
    }

    private void OnEnable()
    {
        m_Dic = GetAllCheckConfig();
    }

    private void OnGUI()
    {

        foreach (var item in m_Dic)
        {
            var on = m_hash.Contains(item.Key);
            var newOn = EditorGUILayout.Toggle(item.Key.ToString(), on);
            if (on != newOn)
            {
                if (newOn)
                {
                    m_hash.Add(item.Key);
                }
                else
                {
                    m_hash.Remove(item.Key);
                }
            }
        }

        CherkRes(false, s => { return !m_hash.Contains(s); });
    }

    public Dictionary<Test, int> GetAllCheckConfig()
    {
        Dictionary<Test, int> dic = new Dictionary<Test, int>();
        dic.Add(Test.测试1, 1);
        dic.Add(Test.测试2, 2);
        dic.Add(Test.测试3, 3);
        return dic;
    }

    private void CherkRes(bool repair, Func<Test, bool> filter)
    {
        var map = GetAllCheckConfig();

        foreach (var item in map)
        {
            Debug.LogError(filter(item.Key));
        }
    }

}

