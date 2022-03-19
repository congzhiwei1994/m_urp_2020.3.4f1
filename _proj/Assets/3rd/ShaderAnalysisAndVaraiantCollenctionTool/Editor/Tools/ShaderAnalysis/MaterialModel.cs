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
    public class MaterialModel : AnalysisBase
    {
        private Dictionary<Material, string> materialRespDic = new Dictionary<Material, string>();
        Material singleMaterial;

        public override string GetModelDes()
        {
            return "材质变体检测模式，检查材质使用的Shader变体数";
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
                singleMaterial = (Material)EditorGUILayout.ObjectField(singleMaterial, typeof(Material), true, GUILayout.Width(200));
            }
            GUILayout.EndHorizontal();
        }
        public override void StartAnalysis()
        {
            // collection Obj -- set Analysis data - report
            searchStr = "";
            modelName = "MaterialAnalysis";
            List<Material> materialList = new List<Material>();
            if (isSingle)
            {
                if (singleMaterial != null)
                    materialList.Add(singleMaterial);
            }
            else
            {
                var materials = Directory.GetFiles("Assets/", "*.mat", SearchOption.AllDirectories);
                for (int i = 0; i < materials.Length; i++)
                {
                    var m = AssetDatabase.LoadAssetAtPath(materials[i], typeof(Material)) as Material;
                    materialList.Add(m);
                }
            }
            materialRespDic.Clear();
            for (int i = 0; i < materialList.Count; i++)
            {
                Material m = materialList[i];
                var shader = m.shader;
                var variantCount = InvokeInternalStaticMethod(typeof(ShaderUtil), "GetVariantCount", new System.Object[] { shader, false });
                materialRespDic.Add(m, variantCount.ToString());
            }
        }

        public override void AnalysisReprot()
        {
            if (materialRespDic.Count == 0)
            {
                return;
            }
            searchStr = EditorGUILayout.TextField(searchStr);
            scrollPos = GUILayout.BeginScrollView(scrollPos, false, false, GUILayout.Width(600), GUILayout.Height(500));
            foreach (KeyValuePair<Material, string> data in materialRespDic)
            {
                var material = data.Key;
                var num = data.Value;
                if (!material.name.ToLower().Contains(searchStr.ToLower()))
                    continue;
                GUILayout.BeginHorizontal();
                EditorGUILayout.ObjectField(material, typeof(Material), true, GUILayout.Width(200));
                m_tempFontStyle.normal.textColor = int.Parse(num) < 20 ? Color.white : Color.red;
                EditorGUILayout.LabelField("变体总数:" + num, m_tempFontStyle, GUILayout.Width(100));
                EditorGUILayout.LabelField("Shader : ", GUILayout.Width(50));
                EditorGUILayout.ObjectField(material.shader, typeof(Shader), true, GUILayout.Width(200));
                GUILayout.EndHorizontal();
            }
            GUILayout.EndScrollView();
        }
        public override void AnalysisSummary()
        {
            if (materialRespDic.Count == 0)
                return;

            int mVariantShader = 0;
            int lVariantShader = 0;
            Dictionary<Shader, string> shaderDir = new Dictionary<Shader, string>();
            foreach (KeyValuePair<Material, string> data in materialRespDic)
            {
                var material = data.Key;
                var variantCount = data.Value;
                if (int.Parse(variantCount) >= 20)
                {
                    mVariantShader += 1;
                    if (int.Parse(variantCount) >= 100)
                        lVariantShader += 1;

                    if (!shaderDir.ContainsKey(material.shader))
                    {
                        shaderDir[material.shader] = variantCount;
                    }
                }
            }
            GUILayout.BeginVertical();
            EditorGUILayout.LabelField("总结:", GUILayout.Width(600));
            GUILayout.BeginHorizontal();

            EditorGUILayout.LabelField("分析材质总数:【" + materialRespDic.Count + "】", GUILayout.Width(300));
            EditorGUILayout.LabelField("Tip：变体总量为shader全编译时的变体总和", GUILayout.Width(300));
            GUILayout.EndHorizontal();
            GUILayout.BeginHorizontal();

            EditorGUILayout.LabelField("超过20个变体总量的shader数:【" + mVariantShader + "】", GUILayout.Width(300));
            EditorGUILayout.LabelField("超过100个变体总量的shader数:【" + lVariantShader + "】", GUILayout.Width(300));
            GUILayout.EndHorizontal();

            summaryScrollPos = GUILayout.BeginScrollView(summaryScrollPos, false, false, GUILayout.Width(600), GUILayout.Height(200));
            m_tempFontStyle.normal.textColor = Color.red;

            foreach (KeyValuePair<Shader, string> data in shaderDir)
            {
                GUILayout.BeginHorizontal();
                EditorGUILayout.ObjectField(data.Key, typeof(Shader), true, GUILayout.Width(400));

                EditorGUILayout.LabelField("变体总量:" + data.Value, m_tempFontStyle, GUILayout.Width(150));
                GUILayout.EndHorizontal();
            }
            GUILayout.EndScrollView();
            GUILayout.EndVertical();

            stringBuilder.Clear();
            stringBuilder.Append(string.Format("模式：{0}\n", GetModelDes()));
            stringBuilder.Append(string.Format("分析材质总数:【{0}】\n", materialRespDic.Count));
            stringBuilder.Append(string.Format("超过20个变体总量的shader数【{0}】，超过100个变体总量的shader数【{1}】\n", mVariantShader, lVariantShader));
            stringBuilder.Append(string.Format("分析结果，以下内容可以复制到excel里\n"));
            stringBuilder.Append(string.Format("===================================================================\n"));
            stringBuilder.Append("材质名\t使用的Shader\tShader编译变体数\n");

            foreach (KeyValuePair<Material, string> data in materialRespDic)
            {
                stringBuilder.Append(string.Format("{0}\t{1}\t{2}\n", data.Key.name, data.Key.shader.name, data.Value));
            }
            SaveResult(modelName);
        }

    }
}