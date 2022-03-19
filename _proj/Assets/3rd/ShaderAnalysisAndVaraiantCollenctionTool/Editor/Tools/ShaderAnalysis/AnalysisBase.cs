/*
    Data:2021-10
    By:uyself
*/
using UnityEngine;
using UnityEditor;
using System.IO;
using System.Reflection;
using System.Text;

namespace Uy.ShaderAnalysis
{
    public class AnalysisBase
    {
        public StringBuilder stringBuilder = new StringBuilder();
        public string searchStr = "";
        public string modelName = "";

        public Vector2 scrollPos = Vector2.zero;
        public Vector2 summaryScrollPos = Vector2.zero;
        public GUIStyle m_tempFontStyle = new GUIStyle();
        public bool isSingle = false;

        public virtual string GetModelDes()
        {
            return "";
        }
        public virtual string GetButtonName()
        {
            return "";
        }
        public virtual void ShowGUI()
        {

        }
        public virtual void StartAnalysis()
        {

        }

        public virtual void AnalysisReprot()
        {

        }

        public virtual void AnalysisSummary()
        {

        }

        public virtual void SaveResult(string model)
        {
            if (GUILayout.Button("分析结果导出Txt"))
            {
                string str = AnalysisConsts.exportTxtRootPath + model + ".txt";
                StreamWriter sw = new StreamWriter(str);
                sw.Write(stringBuilder.ToString());
                sw.Close();
                sw.Dispose();
                AssetDatabase.SaveAssets();
                AssetDatabase.Refresh();
            }
        }
        public static object InvokeInternalStaticMethod(System.Type type, string method, params object[] parameters)
        {
            var methodInfo = type.GetMethod(method, BindingFlags.NonPublic | BindingFlags.Static);
            if (methodInfo == null)
            {
                Debug.LogError(string.Format("{0} method didn't exist", method));
                return null;
            }

            return methodInfo.Invoke(null, parameters);

        }
    }
}