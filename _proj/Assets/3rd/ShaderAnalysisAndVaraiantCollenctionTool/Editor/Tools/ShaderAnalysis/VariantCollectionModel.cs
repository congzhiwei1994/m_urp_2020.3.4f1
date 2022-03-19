/*
    Data:2021-10
    By:uyself
*/
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;
using UnityEditor.SceneManagement;
using static Uy.ShaderAnalysis.AnalysisConsts;

namespace Uy.ShaderAnalysis
{
    public class VariantCollectionModel : AnalysisBase
    {
        bool SVCEnv = false;
        string ShaderVariantCollectionPath = "Assets/ShaderVariantCollection.shadervariants";
        string ShaderVariantCollectionExtraPath = "Assets/ShaderVariantCollectionExtra.shadervariants";
        public override string GetModelDes()
        {
            return "变体收集器模式";
        }
        public override string GetButtonName()
        {
            return "创建收集环境";
        }
        public override void ShowGUI()
        {
            EditorGUILayout.LabelField("需要创建收集环境后才能收集到正确变体", GUILayout.Width(400));
        }
        public override void StartAnalysis()
        {
            // collection Obj -- set Analysis data - report
            SVCEnv = false;
            CreateAllMaterial();
        }

        public override void AnalysisReprot()
        {
            EditorGUILayout.LabelField("当前收集情况：", GUILayout.Width(200));
            if (GUILayout.Button("清除收集器缓存", GUILayout.Height(35)))
            {
                InvokeInternalStaticMethod(typeof(ShaderUtil), "ClearCurrentShaderVariantCollection");
                AssetDatabase.DeleteAsset(ShaderVariantCollectionPath);
            }
            if (GUILayout.Button("保存收集器数据", GUILayout.Height(35)))
            {
                InvokeInternalStaticMethod(typeof(ShaderUtil), "SaveCurrentShaderVariantCollection",
                               ShaderVariantCollectionPath);
                Select(ShaderVariantCollectionPath);
            }
            if (GUILayout.Button("创建手动收集器文件（若已存在则不会创建）", GUILayout.Height(35)))
            {
                if (!File.Exists(ShaderVariantCollectionExtraPath))
                {
                    var extra = new ShaderVariantCollection();
                    AssetDatabase.CreateAsset(extra, ShaderVariantCollectionExtraPath);
                    EditorUtility.SetDirty(extra);
                    AssetDatabase.SaveAssets();
                    AssetDatabase.Refresh();
                }
                Select(ShaderVariantCollectionExtraPath);
            }
            var sCount = InvokeInternalStaticMethod(typeof(ShaderUtil), "GetCurrentShaderVariantCollectionShaderCount");
            var vCount = InvokeInternalStaticMethod(typeof(ShaderUtil), "GetCurrentShaderVariantCollectionVariantCount");
            EditorGUILayout.LabelField("【变体收集器信息】当前总shader收集数：" + sCount, GUILayout.Width(400));
            EditorGUILayout.LabelField("【变体收集器信息】当前总变体收集数：" + vCount, GUILayout.Width(400));
        }
        public override void AnalysisSummary()
        {

        }
        private void CreateAllMaterial()
        {
            var ms = new List<Material>();
            var tempMaterialsPath = Directory.GetFiles("Assets/", "*.mat", SearchOption.AllDirectories);
            for (int i = 0; i < tempMaterialsPath.Length; i++)
            {
                var m = AssetDatabase.LoadAssetAtPath(tempMaterialsPath[i], typeof(Material)) as Material;

                ms.Add(m);
            }

            EditorSceneManager.NewScene(NewSceneSetup.DefaultGameObjects);
            ProcessMaterials(ms);
            SVCEnv = true;
        }

        public void Select(string path)
        {
            Object obj = AssetDatabase.LoadMainAssetAtPath(path);
            if (obj == null)
                return;
            EditorGUIUtility.PingObject(obj);
            Selection.activeObject = obj;
        }
        private void SetKeyWord(string key, bool open)
        {
            //XC_CUSTOMSHADER_LEVER_HIGH
            if (open)
            {
                Shader.EnableKeyword(key);
            }
            else
            {
                Shader.DisableKeyword(key);
            }
        }
        private void ProcessMaterials(List<Material> materials)
        {
            int totalMaterials = materials.Count;
            var camera = Camera.main;
            if (camera == null)
            {
                Debug.LogError("Main Camera didn't exist");
                return;
            }

            float aspect = camera.aspect;

            float height = Mathf.Sqrt(totalMaterials / aspect) + 1;
            float width = Mathf.Sqrt(totalMaterials / aspect) * aspect + 1;

            float halfHeight = Mathf.CeilToInt(height / 2f);
            float halfWidth = Mathf.CeilToInt(width / 2f);

            camera.orthographic = true;
            camera.orthographicSize = halfHeight;
            camera.transform.position = new Vector3(0f, 0f, -10f);

            //聚焦
            Selection.activeGameObject = camera.gameObject;
            EditorApplication.ExecuteMenuItem("GameObject/Align View to Selected");

            int xMax = (int)(width - 1);

            int x = 0;
            int y = 0;

            for (int i = 0; i < materials.Count; i++)
            {
                var material = materials[i];

                var position = new Vector3(x - halfWidth + 1f, y - halfHeight + 1f, 0f);
                CreateSphere(material, position, x, y, i);

                if (x == xMax)
                {
                    x = 0;
                    y++;
                }
                else
                {
                    x++;
                }
            }
        }
        private void CreateSphere(Material material, Vector3 position, int x, int y, int index)
        {
            var go = GameObject.CreatePrimitive(PrimitiveType.Sphere);
            go.GetComponent<Renderer>().material = material;
            go.transform.position = position;
            go.name = string.Format("Sphere_{0}|{1}_{2}|{3}", index, x, y, material.name);
        }

        public ShaderVariantData GetShaderEntriesData(Shader sd, ShaderVariantCollection svc, ref List<string> SelectedKeywords, int maxEntries = 256)
        {
            string[] keywordLists = null, remainingKeywords = null;
            int[] FilteredVariantTypes = null;
            object[] args = new object[] {
            sd,
            maxEntries,
            SelectedKeywords.ToArray (),
            svc,
            FilteredVariantTypes,
            keywordLists,
            remainingKeywords
            };
            InvokeInternalStaticMethod(typeof(ShaderUtil), "GetShaderVariantEntriesFiltered", args);
            ShaderVariantData svd = new ShaderVariantData();
            svd.passTypes = args[4] as int[];
            svd.keywordLists = args[5] as string[];
            svd.remainingKeywords = args[6] as string[];
            return svd;
        }
    }
}