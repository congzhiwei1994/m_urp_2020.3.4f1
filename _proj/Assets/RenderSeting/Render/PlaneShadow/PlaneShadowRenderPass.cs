using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace Render
{
    public class PlaneShadowRenderPass : ScriptableRenderPass
    {
        PlaneShadowRenderFeature.FilterSettings settings;
        public PlaneShadowRenderPass(PlaneShadowRenderFeature.FilterSettings settings)
        {
            this.settings = settings;
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            throw new System.NotImplementedException();
        }

    }

}
