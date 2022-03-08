using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

namespace XS.TA.ShaderTools
{
    public class ShaderReplaceWindow : EditorWindow
    {
        [MenuItem("TA/Shader Replace Man", false, 100)]
        public static void OnOpenEditor()
        {
            var window = (ShaderReplaceWindow)EditorWindow.GetWindow<ShaderReplaceWindow>();
            window.titleContent = new GUIContent("Shader Replace Man");
            window.minSize = new Vector2(300, 300);
            window.Show();
        }

        private Shader m_OldShader;
        private Shader m_NewShader;
        private DefaultAsset m_Folder;
        private List<Material> m_Materials = new List<Material>();
        private Vector2 m_MaterialListPos = Vector2.zero;

        void OnGUI()
        {
            var oldShader = EditorGUILayout.ObjectField("Old Shader", m_OldShader, typeof(Shader), false) as Shader;
            if (oldShader != m_OldShader)
            {
                m_OldShader = oldShader;
                FindReferencesMaterials();
            }

            var newShader = EditorGUILayout.ObjectField("New Shader", m_NewShader, typeof(Shader), false) as Shader;
            if (newShader != m_NewShader)
            {
                m_NewShader = newShader;
            }

            var folder = (DefaultAsset)EditorGUILayout.ObjectField("Search Folder", m_Folder, typeof(DefaultAsset), false);
            if (folder != m_Folder)
            {
                m_Folder = folder;
                FindReferencesMaterials();
            }

            EditorGUILayout.BeginHorizontal();
            {
                GUILayout.FlexibleSpace();


                if (GUILayout.Button("Refresh", GUILayout.Width(80)))
                {
                    FindReferencesMaterials();
                }

                if (GUILayout.Button("Replace (" + m_Materials.Count + ")", GUILayout.Width(80)))
                {
                    ReplaceAllShaders();
                }
            }
            EditorGUILayout.EndHorizontal();

            m_MaterialListPos = EditorGUILayout.BeginScrollView(m_MaterialListPos);
            {
                foreach (var mat in m_Materials)
                {
                    EditorGUILayout.ObjectField(mat, typeof(Material), false);
                }
            }
            EditorGUILayout.EndScrollView();
        }

        void FindReferencesMaterials()
        {
            if (m_OldShader == null || m_Folder == null)
            {
                return;
            }

            m_Materials.Clear();

            var allMaterialGUIDs = AssetDatabase.FindAssets("t:material", new string[] { AssetDatabase.GetAssetPath(m_Folder) });
            foreach (var guid in allMaterialGUIDs)
            {
                var path = AssetDatabase.GUIDToAssetPath(guid);
                var mat = AssetDatabase.LoadAssetAtPath<Material>(path);
                if (mat.shader != null && mat.shader.name == m_OldShader.name)
                {
                    m_Materials.Add(mat);
                }
            }
        }

        void ReplaceAllShaders()
        {
            if (m_Materials.Count == 0)
            {
                ShowNotification(new GUIContent("No corresponding material found!"));
                return;
            }

            if (m_OldShader == m_NewShader)
            {
                ShowNotification(new GUIContent("Replaces the same shader"));
                return;
            }

            for (var i = 0; i < m_Materials.Count; i++)
            {
                var material = m_Materials[i];

                if (EditorUtility.DisplayCancelableProgressBar("Replace", material.name, i / (float)m_Materials.Count))
                {
                    break;
                }

                material.shader = m_NewShader;
            }

            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();
            EditorUtility.ClearProgressBar();
            ShowNotification(new GUIContent("A total of " + m_Materials.Count + "material changes"));
        }
    }
}