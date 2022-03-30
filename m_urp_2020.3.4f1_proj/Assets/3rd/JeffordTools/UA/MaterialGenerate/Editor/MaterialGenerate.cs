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
        /// <summary>
        /// 材质生成器的类型
        /// </summary>
        /// <value></value>
        public static List<Type> m_AllConfigType
        {
            get
            {
                if (m_allConfigType == null || m_allConfigType.Count == 0)
                {
                    // 获取所有继承自MaterialConfig类并且不为Abstract(抽象)类，并且将其转换成集合
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
            // 获取目录名
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
            // 指定重写的对象
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
            });
            Debug.LogError("selectIndex" + "======" + selectIndex);

            // 将继承自MaterialConfig的非抽象类的类型转换成string类型
            var nameList = MaterialGenerate.m_AllConfigType.ConvertAll<string>(type =>
            {
                var t = CreateInstance(type) as MaterialConfig;
                return t.GetDisPlayName();
            });

            // 获取材质生成器的路径
            var path = AssetDatabase.GetAssetPath(m_materialGenetate);

            // 选取config材质类型
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

                m_materialGenetate.m_config = null;
                config = null;
                // 更新Index
                selectIndex = newIndex;

                Type selectType = null;
                if (selectIndex >= 0 && selectIndex < MaterialGenerate.m_AllConfigType.Count)
                {
                    selectType = MaterialGenerate.m_AllConfigType[selectIndex];
                }

                if (selectType != null)
                {
                    config = (MaterialConfig)CreateInstance(selectType);
                    config.name = config.GetDisPlayName();
                    m_materialGenetate.m_config = config;
                    // 将 config 添加到指定路径path处的Asset文件
                    AssetDatabase.AddObjectToAsset(config, path);
                }
                // 重新导入路径path下的资源
                AssetDatabase.ImportAsset(path);
                // 将资源写入磁盘
                AssetDatabase.SaveAssets();
            }

            if (config != null)
            {
                if (GUILayout.Button("生成或者更新"))
                {
                    config.GenerateMaterial();
                }
            }

        }
    }

}
