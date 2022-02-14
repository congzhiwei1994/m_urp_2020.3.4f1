using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace App.Render
{
    public class RealTimeShadowRenderFeature : ScriptableRendererFeature
    {

        [System.Serializable]
        public class RealShadowSettings
        {
            public string PassTag = "RealTimeShadow";

            public RenderPassEvent renderPassEvent = RenderPassEvent.BeforeRendering;
        }
        UniversalRenderPipelineAsset rpAssets;
        RealTimeShadowRenderPass m_ScriptablePass;
        public RealShadowSettings settings = new RealShadowSettings();

        public override void Create()
        {
            rpAssets = (UniversalRenderPipelineAsset)GraphicsSettings.currentRenderPipeline;
            m_ScriptablePass = new RealTimeShadowRenderPass(settings, rpAssets);
        }
        public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
        {
            renderer.EnqueuePass(m_ScriptablePass);
        }


    }
}

