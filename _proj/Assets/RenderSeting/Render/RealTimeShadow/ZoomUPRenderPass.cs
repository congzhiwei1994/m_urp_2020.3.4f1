using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

/// <summary>
/// 此Pass类用于对图像进行操作
/// </summary>
public class ZoomUPRenderPass : ScriptableRenderPass
{
    // 创建DestID
    private int destID = Shader.PropertyToID("_TempID");
    ZoomUPRenderFeature.ShadowSettings settings;

    public ZoomUPRenderPass(ZoomUPRenderFeature.ShadowSettings settings)
    {
        this.settings = settings;
    }
    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
    {
        // 拿到相机最终的画面
        var source = renderingData.cameraData.renderer.cameraColorTarget;
        // 在CommandBufferPool中获取一个CommandBuffer
        var cmd = CommandBufferPool.Get("ScriptableRenderPass");
        // 获取原相机配置的属性
        var descriptor = renderingData.cameraData.cameraTargetDescriptor;

        // 原相机属性到临时RT(destID)中
        cmd.GetTemporaryRT(destID, descriptor);
        // source => destID
        cmd.Blit(source, destID);
        // 将原图放大2倍，左下角为(0,0)点
        cmd.Blit(destID, source, new Vector2(0.5f, 0.5f), Vector2.zero);
        // 执行
        context.ExecuteCommandBuffer(cmd);
        // 释放
        CommandBufferPool.Release(cmd);
    }
}
