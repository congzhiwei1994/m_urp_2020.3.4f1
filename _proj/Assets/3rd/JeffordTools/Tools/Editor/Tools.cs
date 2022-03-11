using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

namespace Jefford.Tools
{
    public class Tools : EditorWindow
    {
        private Dictionary<int, string> m_typeDic = new Dictionary<int, string>();
        private List<string> m_typeNameList = new List<string>();
        private int m_typeID;

        [MenuItem("Jefford/工具合集 &x")]
        private static void Window()
        {
            var win = GetWindow<Tools>("工具集");
            win.Show();
        }

        private void OnEnable()
        {
            InitView();
        }
        void InitView()
        {
            m_typeDic.Add(0, "美术");
            m_typeDic.Add(1, "TA");
            m_typeDic.Add(2, "资源检测");

            m_typeNameList.Clear();
            foreach (var item in m_typeDic)
            {
                m_typeNameList.Add(item.Value);
            }

        }
        void OnGUI()
        {
            DrawTypeGUI();
        }

        void DrawTypeGUI()
        {
            EditorGUILayout.BeginHorizontal(GUILayout.ExpandWidth(true), GUILayout.Height(30));
            {
                EditorGUILayout.LabelField(" ", GUILayout.Width(100), GUILayout.Height(30));
                var typeID = GUILayout.SelectionGrid(m_typeID, m_typeNameList.ToArray(), m_typeDic.Count, GUILayout.ExpandHeight(true));
                if (typeID != m_typeID)
                {
                    m_typeID = typeID;
                }
            }
            EditorGUILayout.EndHorizontal();
        }

        private void OnDisable()
        {
        }

    }

}
