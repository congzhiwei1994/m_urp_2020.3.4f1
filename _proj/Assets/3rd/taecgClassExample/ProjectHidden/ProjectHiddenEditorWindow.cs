using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class ProjectHiddenEditorWindow : EditorWindow
{
    private const string m_subPath = "Assets";
    private string[] m_subfolder;
    private bool[] m_isHide;

    [MenuItem("TA/Project隐藏")]
    static void Open()
    {
        var win = GetWindow<ProjectHiddenEditorWindow>("Project隐藏");
        win.Show();
    }

    private void OnEnable()
    {
        m_subfolder = AssetDatabase.GetSubFolders(m_subPath);
        m_isHide = new bool[m_subfolder.Length];

        for (var i = 0; i < m_subfolder.Length; i++)
        {
            string key = string.Format("m_subfolderHidden_{0}", m_subfolder[i]);
            m_isHide[i] = EditorPrefs.GetBool(key, true);
        }
    }

    private void OnDisable()
    {
        for (var i = 0; i < m_subfolder.Length; i++)
        {
            string key = string.Format("m_subfolderHidden_{0}", m_subfolder[i]);
            EditorPrefs.SetBool(key, m_isHide[i]);
        }
    }
    private void OnGUI()
    {
        for (var i = 0; i < m_subfolder.Length; i++)
        {
            var isHide = EditorGUILayout.ToggleLeft(m_subfolder[i], m_isHide[i]);
            if (isHide != m_isHide[i])
            {
                m_isHide[i] = isHide;
            }
        }

    }
}
