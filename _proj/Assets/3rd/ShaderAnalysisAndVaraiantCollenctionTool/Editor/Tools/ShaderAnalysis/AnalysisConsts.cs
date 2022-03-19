/*
    Data:2021-10
    By:uyself
*/
using UnityEngine;
namespace Uy.ShaderAnalysis
{
    public static class AnalysisConsts
    {
        public enum Options
        {
            shader_model = 0, //shader_materials
            material_model = 1, //material_shaderVariant
            prefab_model = 2,// prefab model
            ShaderVariantCollection = 3, // ShaderVariantCollection
        }
        public class ShaderVariantData
        {
            public Shader shader;
            public int[] passTypes;
            public string[] keywordLists;
            public string[] remainingKeywords;
        }

        public const string extraAssetPath = "Assets/ShaderAnalysisAsset.asset";
        public const string extraSVCPath = "Assets/ShaderVariantCollectionExtra.shadervariants";
        public const string exportTxtRootPath = "Assets/Editor/Tools/ShaderAnalysis/Data/";
    }
}