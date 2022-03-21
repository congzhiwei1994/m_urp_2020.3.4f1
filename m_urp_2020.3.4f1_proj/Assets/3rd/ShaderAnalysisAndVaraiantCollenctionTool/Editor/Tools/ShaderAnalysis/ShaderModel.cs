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
    public class ShaderModel : AnalysisBase
    {
        private Dictionary<Shader, List<Material>> shaderRespDic = new Dictionary<Shader, List<Material>>();
        Shader singleShader;
        public override string GetModelDes()
        {
            return "Shader材质检测模式，检查项目中Shader在项目的材质静态引用情况";
        }
        public override string GetButtonName()
        {
            return "开始分析";
        }
        public override void ShowGUI()
        {
            GUILayout.BeginHorizontal();

            EditorGUILayout.LabelField("是否开启单体分析:", GUILayout.Width(120));
            isSingle = EditorGUILayout.Toggle(isSingle);
            if (isSingle)
            {
                singleShader = (Shader)EditorGUILayout.ObjectField(singleShader, typeof(Shader), true, GUILayout.Width(200));
            }
            GUILayout.EndHorizontal();
        }
        public override void StartAnalysis()
        {
            // collection Obj -- set Analysis data - report
            List<Shader> shaderList = new List<Shader>();
            searchStr = "";
            modelName = "ShaderAnalysis";
            if (isSingle)
            {
                if (singleShader != null)
                    shaderList.Add(singleShader);
            }
            else
            {
                var shaders = Directory.GetFiles("Assets/", "*.shader", SearchOption.AllDirectories);
                for (int i = 0; i < shaders.Length; i++)
                {
                    var s = AssetDatabase.LoadAssetAtPath(shaders[i], typeof(Shader)) as Shader;
                    shaderList.Add(s);
                }
            }
            shaderRespDic.Clear();
            var tempMaterialsPath = Directory.GetFiles("Assets/", "*.mat", SearchOption.AllDirectories);
            for (int i = 0; i < shaderList.Count; i++)
            {
                shaderRespDic.Add(shaderList[i], new List<Material>());
            }
            for (int i = 0; i < tempMaterialsPath.Length; i++)
            {
                var m = AssetDatabase.LoadAssetAtPath(tempMaterialsPath[i], typeof(Material)) as Material;
                if (shaderRespDic.ContainsKey(m.shader))
                {
                    shaderRespDic[m.shader].Add(m);
                }
            }
        }

        public override void AnalysisReprot()
        {
            if (shaderRespDic.Count == 0)
            {
                return;
            }
            searchStr = EditorGUILayout.TextField(searchStr);
            scrollPos = GUILayout.BeginScrollView(scrollPos, false, false, GUILayout.Width(600), GUILayout.Height(500));
            foreach (KeyValuePair<Shader, List<Material>> data in shaderRespDic)
            {
                var shader = data.Key;
                var materials = data.Value;
                if (!shader.name.ToLower().Contains(searchStr.ToLower()))
                    continue;
                GUILayout.BeginVertical();
                GUILayout.BeginHorizontal();
                EditorGUILayout.ObjectField(shader, typeof(Shader), true, GUILayout.Width(200));
                EditorGUILayout.LabelField("静态引用材质数:" + materials.Count, GUILayout.Width(198));
                GUILayout.EndHorizontal();

                foreach (var m in materials)
                {
                    GUILayout.BeginHorizontal();
                    EditorGUILayout.LabelField("", GUILayout.Width(5));
                    EditorGUILayout.ObjectField(m, typeof(Material), true, GUILayout.Width(200));
                    GUILayout.EndHorizontal();
                }
                GUILayout.EndVertical();
            }
            GUILayout.EndScrollView();
        }

        public override void AnalysisSummary()
        {
            if (shaderRespDic.Count == 0)
                return;
            int materialCout = 0;
            int zeroRef = 0;
            Dictionary<Shader, int> fiveShader = new Dictionary<Shader, int>();
            foreach (KeyValuePair<Shader, List<Material>> data in shaderRespDic)
            {
                var shader = data.Key;
                var materials = data.Value;
                var count = materials.Count;
                if (count == 0)
                {
                    zeroRef += 1;
                }
                if (count >= 5)
                {
                    fiveShader.Add(shader, count);
                }
                materialCout += count;
            }
            GUILayout.BeginVertical();
            EditorGUILayout.LabelField("总结:", GUILayout.Width(600));
            EditorGUILayout.LabelField(string.Format("分析Shader总数:【{0}】,引用材质总数:【{1}】", shaderRespDic.Count, materialCout));
            EditorGUILayout.LabelField("存在==0个静态引用材质的shader数:【" + zeroRef + "】" + (zeroRef > 0 ? "请检查是否有shader是不使用的，注意是否为动态引用" : ""));
            EditorGUILayout.LabelField("存在>=5个静态引用材质的shader数:【" + fiveShader.Count + "】");
            summaryScrollPos = GUILayout.BeginScrollView(summaryScrollPos, false, false, GUILayout.Width(600), GUILayout.Height(180));

            foreach (KeyValuePair<Shader, int> data in fiveShader)
            {
                GUILayout.BeginHorizontal();
                EditorGUILayout.ObjectField(data.Key, typeof(Shader), true, GUILayout.Width(200));
                EditorGUILayout.LabelField("引用材质数:" + data.Value);
                GUILayout.EndHorizontal();
                stringBuilder.Append(string.Format("{0}\t{1}\n", data.Key.name, data.Value));
            }
            GUILayout.EndScrollView();
            GUILayout.EndVertical();

            stringBuilder.Clear();
            stringBuilder.Append(string.Format("模式：{0}\n", GetModelDes()));
            stringBuilder.Append(string.Format("分析Shader总数:【{0}】,引用材质总数:【{1}】\n", shaderRespDic.Count, materialCout));
            stringBuilder.Append(string.Format("0个静态引用材质的shader数【{0}】，>=5个静态引用材质的shader数【{1}】\n", fiveShader.Count, materialCout));
            stringBuilder.Append(string.Format("分析结果，以下内容可以复制到excel里\n"));
            stringBuilder.Append(string.Format("===================================================================\n"));

            stringBuilder.Append("Shader名 \t引用材质数 \n");
            foreach (KeyValuePair<Shader, List<Material>> data in shaderRespDic)
            {
                stringBuilder.Append(string.Format("{0}\t{1}\n", data.Key.name, data.Value.Count));
            }
            SaveResult(modelName);
        }
    }

}