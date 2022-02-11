using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace Render
{
    public class PlaneShadowRenderFeature : ScriptableRendererFeature
    {
        [System.Serializable]
        public class FilterSettings
        {
            public string passTag = "ShadowSettingRender";
            public RenderPassEvent renderPassEvent = RenderPassEvent.BeforeRendering;
        }

        FilterSettings settings = new FilterSettings();
        PlaneShadowRenderPass planeShadowRenderPass;

        public override void Create()
        {
            planeShadowRenderPass = new PlaneShadowRenderPass(settings);
        }

        public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
        {
            throw new System.NotImplementedException();
        }
    }
}

