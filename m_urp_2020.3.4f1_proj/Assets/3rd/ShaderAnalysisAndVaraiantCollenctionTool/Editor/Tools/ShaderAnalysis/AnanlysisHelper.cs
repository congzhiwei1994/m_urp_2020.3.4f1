/*
    Data:2021-10
    By:uyself
*/
using static Uy.ShaderAnalysis.AnalysisConsts;

namespace Uy.ShaderAnalysis
{
    public class AnalysisHelper
    {
        private static AnalysisHelper helper;
        private Options curOption;

        private static ShaderModel shaderModel;
        private static MaterialModel materialModel;
        private static PrefabModel prefabModel;
        private static VariantCollectionModel variantCollectionModel;

        private AnalysisHelper()
        {

        }
        public static AnalysisHelper GetHelperIns()
        {
            if (helper == null)
            {
                helper = new AnalysisHelper();
                shaderModel = new ShaderModel();
                materialModel = new MaterialModel();
                prefabModel = new PrefabModel();
                variantCollectionModel = new VariantCollectionModel();
            }
            return helper;
        }

        public void SetModel(Options option)
        {
            if (curOption != option)
            {
                curOption = option;
            }
        }
        public dynamic GetModel()
        {
            dynamic model = null;
            switch (curOption)
            {
                case Options.shader_model:
                    model = shaderModel;
                    break;
                case Options.material_model:
                    model = materialModel;
                    break;
                case Options.prefab_model:
                    model = prefabModel;
                    break;
                case Options.ShaderVariantCollection:
                    model = variantCollectionModel;
                    break;
            }
            return model;
        }
    }
}