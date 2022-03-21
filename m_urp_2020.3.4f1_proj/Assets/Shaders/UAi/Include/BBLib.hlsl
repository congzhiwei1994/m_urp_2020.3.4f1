#ifndef BBLIB_INCLUDED
#define BBLIB_INCLUDED


// ���½ӿ��ǿ��Թ̶�y���billboard������ ������

// Ϊ0ʱ.�̶�y�ᣬ������������Ӧ�����ڵر��£���Ӧ��Ҳ��׼��Ļ


float4 ObjectToClipPosWorldBillboard(float4 vertex, float3 center, float verticalBillboardingX, float verticalBillboardingY, float verticalBillboardingZ) {

    float4 viewer = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1));
    float3 normalDir = viewer.xyz - center;
    normalDir.y = normalDir.y * verticalBillboardingY;
    normalDir.z = normalDir.z * verticalBillboardingZ;
    normalDir.x = normalDir.x * verticalBillboardingX;
    normalDir = normalize(normalDir);

    float3 up = abs(normalDir.y) > 0.999 ? float3(0, 0, 1) : float3(0, 1, 0);
    float3 right = normalize(cross(normalDir, up));
    up = normalize(cross(right, normalDir));

    float3 centerOffs = vertex.xyz - center;

    float3 localPos = center + right * centerOffs.x + up * centerOffs.y + normalDir * centerOffs.z;

    float3 positionWS = TransformObjectToWorld(localPos);

    return TransformWorldToHClip(positionWS);
}

float4 ObjectToClipPosWorldBillboard(float4 vertex, float verticalBillboardingX, float verticalBillboardingY, float verticalBillboardingZ) {

    float3 center = float3(0, 0, 0);

    return ObjectToClipPosWorldBillboard(vertex, center, verticalBillboardingX, verticalBillboardingY, verticalBillboardingZ);
}



// ���¼����ӿ���xy��xz ������̶���׼��Ļ�� billboard����ֱ�ӽű���tr.forwrad = camera.forwardЧ��һ��
// plane
float4 ObjectToClipPosViewBillboardXZ(float4 vertex, float2 size) {

    float4 clipPos = mul(UNITY_MATRIX_P, mul(UNITY_MATRIX_MV, float4(0, 0, 0, 1)) + float4(vertex.x * size.x, vertex.z * size.y, 0, 0.0));
    return clipPos;
}

// quad
float4 ObjectToClipPosViewBillboardXY(float4 vertex, float3 centerPos, float2 size) {

    float4 clipPos = mul(UNITY_MATRIX_P, mul(UNITY_MATRIX_MV, half4(centerPos.xyz, 1.0)) + float4(vertex.x * size.x, vertex.y * size.y, 0, 0.0));
    return clipPos;
}

// quad
float4 ObjectToClipPosViewBillboardXY(float4 vertex, float2 size) {

    return ObjectToClipPosViewBillboardXY(vertex, float3(0, 0, 0), size);
}



// ���������ӿ�Ϊ�̶���Ļ��С��billboard�� һ����ObjectToClipPosClipBillboard1

// �̶���Ļ���ش�С��billboard������particle size
float4 ObjectToClipPosClipBillboard1(float4 vertex, float2 pixelSize) {
    float4 clipPos = mul(UNITY_MATRIX_P, mul(UNITY_MATRIX_MV, float4(0, 0, 0, 1)));

    clipPos.w = 1;

    clipPos.x += vertex.x * (pixelSize.x / _ScreenParams.x * 2.0);
    clipPos.y += vertex.y * (-pixelSize.y / _ScreenParams.y * 2.0);

    return clipPos;
}

float4 ObjectToClipPosClipBillboard2(float4 vertex, float2 size) {

    float4 clipPos = mul(UNITY_MATRIX_P, mul(UNITY_MATRIX_MV, float4(0, 0, 0, 1)));
    clipPos.w = 1;

    clipPos.x += vertex.x * size.x;
    clipPos.y += vertex.y * -size.y;

    return clipPos;
}

#endif
