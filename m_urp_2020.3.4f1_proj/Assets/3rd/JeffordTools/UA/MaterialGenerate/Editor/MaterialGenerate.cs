using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;
using System;
using System.Linq;
using UnityEngine.Rendering;

namespace Jefford.MaterialGenerate
{
    [CreateAssetMenu(menuName = "生成/材质生成器", order = 0)]
    public class MaterialGenerate : ScriptableObject
    {
        [HideInInspector]
        [SerializeField]
        public MaterialConfig m_config;
        public List<Material> m_materialList;

        private static List<Type> m_allConfigType = null;
        public static List<Type> m_AllConfigType
        {
            get
            {
                if (m_allConfigType == null || m_allConfigType.Count == 0)
                {
                    m_allConfigType = CoreUtils.GetAllTypesDerivedFrom<MaterialConfig>().Where(t => !t.IsAbstract).ToList();
                }

                return m_allConfigType;
            }
        }

        public bool CheckPathValid()
        {
            var path = AssetDatabase.GetAssetPath(this);
            if (string.IsNullOrEmpty(path))
            {
                return true;
            }

            var folder = Path.GetDirectoryName(path);
            if (m_materialList == null)
            {
                return true;
            }

            foreach (var mat in m_materialList)
            {
                if (mat == null)
                {
                    continue;
                }

                else
                {
                    var matPath = AssetDatabase.GetAssetPath(mat);
                    var matFolder = Path.GetDirectoryName(matPath);
                    if (folder != matFolder)
                    {
                        return false;
                    }
                }
            }
            return true;
        }
    }

    [CustomEditor(typeof(MaterialGenerate))]
    public class MaterialGenerateEditor : Editor
    {
        public override void OnInspectorGUI()
        {
            base.OnInspectorGUI();
            MaterialGenerate m_materialGenetate;
            m_materialGenetate = this.target as MaterialGenerate;

            if (!m_materialGenetate.CheckPathValid())
            {
                GUILayout.Label("材质不在同一个目录");
                return;
            }

            var config = m_materialGenetate.m_config;

            // 判断并且获取继承MaterialConfig非抽象类的索引
            var selectIndex = MaterialGenerate.m_AllConfigType.FindIndex(type =>
            {
                if (config == null)
                {
                    return false;
                }
                return type == config.GetType();
            }
              );

            // 将继承自MaterialConfig的非抽象类的类型转换成string类型
            var nameList = MaterialGenerate.m_AllConfigType.ConvertAll<string>(type =>
            {
                var t = CreateInstance(type) as MaterialConfig;
                return t.GetDisPlayName();
            }
              );

            var path = AssetDatabase.GetAssetPath(m_materialGenetate);

            var newIndex = EditorGUILayout.Popup(selectIndex, nameList.ToArray());
            if (selectIndex != newIndex)
            {
                // 选取新的Index之后，删除旧的Config
                if (config != null)
                {
                    var assets = AssetDatabase.LoadAllAssetsAtPath(path);
                    foreach (var asset in assets)
                    {
                        if (asset == null || AssetDatabase.IsSubAsset(asset))
                        {
                            AssetDatabase.RemoveObjectFromAsset(asset);
                        }
                    }

                    AssetDatabase.SaveAssets();
                    AssetDatabase.Refresh();
                }
            }

            m_materialGenetate.m_config = null;
            m_config = null;
            selectIndex = newIndex;


        }
    }

}
