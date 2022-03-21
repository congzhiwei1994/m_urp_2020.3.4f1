/*
    Data:2021-10
    By:uyself
*/
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;
namespace Uy.ShaderAnalysis
{
    public class PrefabModel : AnalysisBase
    {
        private Dictionary<GameObject, List<Shader>> prefabResDic = new Dictionary<GameObject, List<Shader>>();
        Object prefabObj;

        public override string GetModelDes()
        {
            return "预制体分析模式";
        }
        public override string GetButtonName()
        {
            return "开始分析";
        }
        public override void ShowGUI()
        {
            prefabObj = (Object)EditorGUILayout.ObjectField(prefabObj, typeof(Object), true, GUILayout.Width(200));
        }
        public override void StartAnalysis()
        {
            // collection Obj -- set Analysis data - report
            searchStr = "";
            modelName = "PrefabAnalysis";
            List<GameObject> goList = new List<GameObject>();
            if (prefabObj == null) return;
            var t = prefabObj.GetType();

            if (t == typeof(GameObject))
            {
                if (PrefabUtility.IsPartOfPrefabAsset(prefabObj))
                {
                    goList.Add((GameObject)prefabObj);
                }
            }
            else if (t == typeof(DefaultAsset))
            {
                var path = AssetDatabase.GetAssetPath(prefabObj);
                var gos = Directory.GetFiles(path, "*.prefab", SearchOption.AllDirectories);
                for (int i = 0; i < gos.Length; i++)
                {
                    var g = AssetDatabase.LoadAssetAtPath(gos[i], typeof(GameObject)) as GameObject;
                    goList.Add(g);
                }
            }
            else
            {
                EditorUtility.DisplayDialog("分析目标类型错误", "请使用预制体或存放预体的文件夹", "ok");
            }

            prefabResDic.Clear();
            for (int i = 0; i < goList.Count; i++)
            {
                GameObject go = goList[i];
                var ms = go.transform.GetComponentsInChildren<MeshRenderer>(true);
                foreach (var m in ms)
                {
                    if (m.sharedMaterial == null)
                        continue;

                    var shader = m.sharedMaterial.shader;
                    if (shader == null)
                        continue;
                    if (!prefabResDic.ContainsKey(go))
                        prefabResDic[go] = new List<Shader>();

                    if (!prefabResDic[go].Contains(shader))
                        prefabResDic[go].Add(shader);

                }
                var sms = go.transform.GetComponentsInChildren<SkinnedMeshRenderer>(true);
                foreach (var m in sms)
                {
                    if (m.sharedMaterial == null)
                        continue;

                    var shader = m.sharedMaterial.shader;
                    if (shader == null)
                        continue;
                    if (!prefabResDic.ContainsKey(go))
                        prefabResDic[go] = new List<Shader>();

                    if (!prefabResDic[go].Contains(shader))
                        prefabResDic[go].Add(shader);
                }
            }
        }

        public override void AnalysisReprot()
        {
            if (prefabResDic.Count == 0)
            {
                return;
            }
            searchStr = EditorGUILayout.TextField(searchStr);
            scrollPos = GUILayout.BeginScrollView(scrollPos, false, false, GUILayout.Width(600), GUILayout.Height(500));
            foreach (KeyValuePair<GameObject, List<Shader>> data in prefabResDic)
            {
                var go = data.Key;
                var shaders = data.Value;
                if (!go.name.ToLower().Contains(searchStr.ToLower()))
                    continue;
                foreach (var shader in shaders)
                {
                    GUILayout.BeginHorizontal();
                    EditorGUILayout.ObjectField(go, typeof(GameObject), true, GUILayout.Width(200));
                    EditorGUILayout.LabelField("Shader : ", GUILayout.Width(50));
                    EditorGUILayout.ObjectField(shader, typeof(Shader), true, GUILayout.Width(200));
                    var variantCount = InvokeInternalStaticMethod(typeof(ShaderUtil), "GetVariantCount", new System.Object[] { shader, false });
                    EditorGUILayout.LabelField("  变体总数:" + variantCount, GUILayout.Width(100));
                    GUILayout.EndHorizontal();
                }
            }
            GUILayout.EndScrollView();
        }
        public override void AnalysisSummary()
        {
            if (prefabResDic.Count == 0)
            {
                return;
            }
            int num20 = 0;
            GUILayout.BeginVertical();
            EditorGUILayout.LabelField("总结:", GUILayout.Width(600));

            EditorGUILayout.LabelField(string.Format("分析预制体总数:【{0}】", prefabResDic.Count), GUILayout.Width(300));
            EditorGUILayout.LabelField("Tip：变体总量为shader全编译时的变体总和", GUILayout.Width(300));

            summaryScrollPos = GUILayout.BeginScrollView(summaryScrollPos, false, false, GUILayout.Width(600), GUILayout.Height(200));
            m_tempFontStyle.normal.textColor = Color.red;
            foreach (KeyValuePair<GameObject, List<Shader>> data in prefabResDic)
            {
                var go = data.Key;
                var shaders = data.Value;

                foreach (var shader in shaders)
                {
                    var variantCount = InvokeInternalStaticMethod(typeof(ShaderUtil), "GetVariantCount", new System.Object[] { shader, false });
                    if (int.Parse(variantCount.ToString()) > 20)
                    {
                        GUILayout.BeginHorizontal();
                        EditorGUILayout.ObjectField(go, typeof(GameObject), true, GUILayout.Width(200));
                        EditorGUILayout.LabelField("Shader : ", GUILayout.Width(50));
                        EditorGUILayout.ObjectField(shader, typeof(Shader), true, GUILayout.Width(200));
                        EditorGUILayout.LabelField("  变体总数:" + variantCount, m_tempFontStyle, GUILayout.Width(100));
                        GUILayout.EndHorizontal();
                        num20 += 1;
                    }
                }
            }
            GUILayout.EndScrollView();
            GUILayout.EndVertical();

            stringBuilder.Clear();
            stringBuilder.Append(string.Format("模式：{0}\n", GetModelDes()));
            stringBuilder.Append(string.Format("分析预制体总数:【{0}】\n", prefabResDic.Count));
            stringBuilder.Append(string.Format("超过20个变体总量的shader数【{0}】\n", num20));
            stringBuilder.Append(string.Format("分析结果，以下内容可以复制到excel里\n"));
            stringBuilder.Append(string.Format("===================================================================\n"));
            stringBuilder.Append("预制体名\t使用的Shader\tShader编译变体数\n");

            foreach (KeyValuePair<GameObject, List<Shader>> data in prefabResDic)
            {
                var shaders = data.Value;
                foreach (var shader in shaders)
                {
                    var variantCount = InvokeInternalStaticMethod(typeof(ShaderUtil), "GetVariantCount", new System.Object[] { shader, false });
                    stringBuilder.Append(string.Format("{0}\t{1}\t{2}\n", data.Key.name, shader.name, variantCount));
                }
            }
            SaveResult(modelName);
        }

    }
}