using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Experimental.Rendering.Universal;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;


public class ParllFeature : ScriptableRendererFeature
{
    public static int maxPass = 20;
    [System.Serializable]
    public class FilterSettings
    {
        public RenderQueueType RenderQueueType;
        public LayerMask LayerMask = 1;
        public string[] PassNames;

        public FilterSettings()
        {
            RenderQueueType = RenderQueueType.Opaque;
            LayerMask = ~0;
            PassNames = new string[] { "ParllFeatureB", "ParllFeatureL" };
        }
    }

    public static ParllFeature instance;

    [System.Serializable]
    public class PassSettings
    {
        public string passTag = "ParllFeature";
        [Header("Settings")]
        public bool ShouldRender = true;
        [Tooltip("Set Layer Num")]
        [Range(1, 200)] public int PassLayerNum = 20;

        public float brightValue = 0.02f;
        public AnimationCurve brightCurveValue;
        [Range(1000, 5000)] public int QueueMin = 2000;
        [Range(1000, 5000)] public int QueueMax = 5000;
        public RenderPassEvent PassEvent = RenderPassEvent.AfterRenderingSkybox;
        public FilterSettings filterSettings = new FilterSettings();
    }

    public class FurRenderPass : ScriptableRenderPass
    {
        string m_ProfilerTag;
        RenderQueueType renderQueueType;
        private PassSettings settings;
        private ParllFeature ParllFeature = null;
        public List<ShaderTagId> m_ShaderTagIdList = new List<ShaderTagId>();
        private ShaderTagId shadowCasterSTI = new ShaderTagId("ShadowCaster");
        private FilteringSettings filter;
        public Material overrideMaterial { get; set; }
        public int overrideMaterialPassIndex { get; set; }

        public FurRenderPass(PassSettings setting, ParllFeature render, FilterSettings filterSettings)
        {
            m_ProfilerTag = setting.passTag;
            string[] shaderTags = filterSettings.PassNames;
            this.settings = setting;
            this.renderQueueType = filterSettings.RenderQueueType;
            ParllFeature = render;
            RenderQueueRange queue = new RenderQueueRange();
            queue.lowerBound = setting.QueueMin;
            queue.upperBound = setting.QueueMax;
            filter = new FilteringSettings(queue, filterSettings.LayerMask);
            if (shaderTags != null && shaderTags.Length > 0)
            {
                foreach (var passName in shaderTags)
                    m_ShaderTagIdList.Add(new ShaderTagId(passName));
            }
        }
     
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            int passLayerNum = System.Math.Min(maxPass, settings.PassLayerNum);
            SortingCriteria sortingCriteria = (renderQueueType == RenderQueueType.Transparent)? SortingCriteria.CommonTransparent
                : renderingData.cameraData.defaultOpaqueSortFlags;
            CommandBuffer cmd = CommandBufferPool.Get(m_ProfilerTag);
        
            DrawingSettings baseDrawingSetting, layerDrawingSetting;
       
            if (m_ShaderTagIdList.Count > 0)
                baseDrawingSetting = CreateDrawingSettings(m_ShaderTagIdList[0], ref renderingData,
                    renderingData.cameraData.defaultOpaqueSortFlags);
            else return;
            if (m_ShaderTagIdList.Count > 1)
                layerDrawingSetting = CreateDrawingSettings(m_ShaderTagIdList[1], ref renderingData,
                    renderingData.cameraData.defaultOpaqueSortFlags);
            else return;
            float inter = 1.0f / passLayerNum;
            float brightValue = settings.brightValue;
      
            cmd.Clear();
            cmd.SetGlobalFloat("_pallPos", 0);
            cmd.SetGlobalFloat("_AlbedoBright", 0);
            context.ExecuteCommandBuffer(cmd);
            context.DrawRenderers(renderingData.cullResults, ref baseDrawingSetting, ref filter);
         
            for (int i = 1; i < passLayerNum; i++)
            {
                cmd.Clear();
                cmd.SetGlobalFloat("_pallPos", i * inter);
                cmd.SetGlobalFloat("_AlbedoBright", Mathf.Pow((i * brightValue) / passLayerNum, passLayerNum)); 

                context.ExecuteCommandBuffer(cmd);
                context.DrawRenderers(renderingData.cullResults, ref layerDrawingSetting, ref filter);
            }
            CommandBufferPool.Release(cmd);
        }

    }
    public PassSettings settings = new PassSettings();
    FurRenderPass m_ScriptablePass;

    public override void Create()
    {
        instance = this;
        FilterSettings filter = settings.filterSettings;
        m_ScriptablePass = new FurRenderPass(settings, this, filter);
        m_ScriptablePass.renderPassEvent = settings.PassEvent;
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(m_ScriptablePass);
    }
}


