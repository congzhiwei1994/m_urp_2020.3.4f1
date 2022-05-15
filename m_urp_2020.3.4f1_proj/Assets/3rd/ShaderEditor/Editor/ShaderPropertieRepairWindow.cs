using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEngine.Rendering;

namespace XS.TA.ShaderTools
{
    public class ShaderPropertieRepairWindow : EditorWindow
    {
        [MenuItem("TA/Shader Propertie Repair", false, 100)]
        public static void OnOpenEditor()
        {
            var window = (ShaderPropertieRepairWindow)EditorWindow.GetWindow<ShaderPropertieRepairWindow>();
            window.titleContent = new GUIContent("Shader Propertie Repair");
            window.minSize = new Vector2(300, 300);
            window.Show();
        }

        [SerializeField]
        private Shader m_Shader;
        [SerializeField]
        private string[] properties;
        [SerializeField]
        private int m_OldProperty;
        [SerializeField]
        private int m_NewProperty;

        void OnGUI()
        {
            var shader = EditorGUILayout.ObjectField("Shader", m_Shader, typeof(Shader), false) as Shader;
            if (shader != m_Shader)
            {
                properties = new string[shader.GetPropertyCount()];
                for(var i = 0; i < shader.GetPropertyCount(); i++)
                {
                    properties[i] = shader.GetPropertyName(i);
                }
                m_Shader = shader;
            }

            if (m_Shader == null)
            {
                return;
            }

            m_OldProperty = EditorGUILayout.Popup("Old Property", m_OldProperty, properties);
            m_NewProperty = EditorGUILayout.Popup("New Property", m_NewProperty, properties);

            EditorGUILayout.BeginHorizontal();
            {
                GUILayout.FlexibleSpace();
                if (GUILayout.Button("Repair", GUILayout.Width(100)))
                {
                    if (m_Shader == null)
                    {
                        EditorUtility.DisplayDialog("Tips", "Shader is Null.", "Close");
                        return;
                    }

                    if (shader.GetPropertyType(m_OldProperty) != shader.GetPropertyType(m_NewProperty))
                    {
                        EditorUtility.DisplayDialog("Tips", "Shader property type mismatch.", "Close");
                        return;
                    }

                    var materials = FindMaterialBy(m_Shader.name);
                    if (materials.Count == 0)
                    {
                        EditorUtility.DisplayDialog("Tips", "No matching material was found.", "Close");
                    }

                    foreach(var material in materials)
                    {
                        Repair(material);
                    }

                    EditorUtility.DisplayDialog("Tips", "Repair success.", "Close");
                    AssetDatabase.SaveAssets();
                    AssetDatabase.Refresh();
                }
            }
            EditorGUILayout.EndHorizontal();
        }

        List<Material> FindMaterialBy(string shaderName)
        {
            var materials = new List<Material>();

            var allMaterials = AssetDatabase.FindAssets("t:material");
            foreach(var path in allMaterials)
            {
                var mat = AssetDatabase.LoadAssetAtPath<Material>(path);
                if (mat.shader.name == shaderName)
                {
                    materials.Add(mat);
                }
            }

            return materials;
        }

        void Repair(Material material)
        {
            Debug.Log("Repair: " + material.name);

            var shader = material.shader;
            var type = shader.GetPropertyType(m_OldProperty);
            var oldName = shader.GetPropertyName(m_OldProperty);
            var newName = shader.GetPropertyName(m_NewProperty);

            switch(type)
            {
                case ShaderPropertyType.Color:
                    material.SetColor(newName, material.GetColor(oldName));
                    break;
                case ShaderPropertyType.Vector:
                    material.SetVector(newName, material.GetVector(oldName));
                    break;
                case ShaderPropertyType.Float:
                    material.SetFloat(newName, material.GetFloat(oldName));
                    break;
                case ShaderPropertyType.Texture:
                    material.SetTexture(newName, material.GetTexture(oldName));
                    break;
            }

            EditorUtility.SetDirty(material);
        }
    }
}