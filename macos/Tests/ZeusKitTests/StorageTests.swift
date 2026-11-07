import Testing
import Foundation
@testable import ZeusKit

// Fixtures captured from a live server (GET only). DR plans, Velero and DataVolumes were empty there,
// so those models follow the OpenAPI spec and are unit-tested only.
private func dec<T: Decodable>(_ t: T.Type, _ s: String) throws -> T { try JSONDecoder().decode(t, from: Data(s.utf8)) }

@Test func decodesStorageClasses() throws {
    let r = try dec([StorageClass].self, #"[{"name":"local-path","provisioner":"rancher.io/local-path","reclaim_policy":"Delete","volume_binding_mode":"WaitForFirstConsumer","allow_volume_expansion":false,"parameters":{},"created_at":"2026-10-26T16:35:39+00:00","is_default":false,"labels":{"objectset.rio.cattle.io/hash":"183f35c65ffbc3064603f43f1580d8c68a2dabd4"},"mount_options":[]},{"name":"zyvor-cephfs-shared","provisioner":"rook-ceph.cephfs.csi.ceph.com","reclaim_policy":"Delete","volume_binding_mode":"Immediate","allow_volume_expansion":true,"parameters":{"clusterID":"rook-ceph","csi.storage.k8s.io/controller-expand-secret-name":"rook-csi-cephfs-provisioner","csi.storage.k8s.io/controller-expand-secret-namespace":"rook-ceph","csi.storage.k8s.io/node-stage-secret-name":"rook-csi-cephfs-node","csi.storage.k8s.io/node-stage-secret-namespace":"rook-ceph","csi.storage.k8s.io/provisioner-secret-name":"rook-csi-cephfs-provisioner","csi.storage.k8s.io/provisioner-secret-namespace":"rook-ceph","fsName":"zyvorfs","pool":"zyvorfs-data0"},"created_at":"2026-10-27T02:20:21+00:00","is_default":false,"labels":{"zyvor.dev/access-mode":"rwx","zyvor.dev/storage-backend":"ceph","zyvor.dev/storage-kind":"file"},"mount_options":[]},{"name":"zyvor-rbd-prod","provisioner":"rook-ceph.rbd.csi.ceph.com","reclaim_policy":"Delete","volume_binding_mode":"Immediate","allow_volume_expansion":true,"parameters":{"clusterID":"rook-ceph","csi.storage.k8s.io/controller-expand-secret-name":"rook-csi-rbd-provisioner","csi.storage.k8s.io/controller-expand-secret-namespace":"rook-ceph","csi.storage.k8s.io/fstype":"ext4","csi.storage.k8s.io/node-stage-secret-name":"rook-csi-rbd-node","csi.storage.k8s.io/node-stage-secret-namespace":"rook-ceph","csi.storage.k8s.io/provisioner-secret-name":"rook-csi-rbd-provisioner","csi.storage.k8s.io/provisioner-secret-namespace":"rook-ceph","imageFeatures":"layering","imageFormat":"2","pool":"rbd-nvme-prod"},"created_at":"2026-10-27T02:20:21+00:00","is_default":true,"labels":{"zyvor.dev/live-migration":"review-required","zyvor.dev/storage-backend":"ceph","zyvor.dev/storage-kind":"block"},"mount_options":[]},{"name":"zyvor-rgw-bucket","provisioner":"rook-ceph.ceph.rook.io/bucket","reclaim_policy":"Delete","volume_binding_mode":"Immediate","allow_volume_expansion":false,"parameters":{"objectStoreName":"zyvor-rgw","objectStoreNamespace":"rook-ceph"},"created_at":"2026-10-27T02:20:22+00:00","is_default":false,"labels":{"zyvor.dev/storage-backend":"ceph","zyvor.dev/storage-kind":"object"},"mount_options":[]}]"#)
    #expect(r.count == 4 && r.contains { $0.isDefault == true && $0.name == "zyvor-rbd-prod" })
}
@Test func decodesStorageClaims() throws {
    let r = try dec([StorageClaim].self, #"[{"name":"atlas-gateway-ceph-data","namespace":"rook-ceph","status":"Bound","volume_name":"pvc-fbd16fce-f09f-42c1-b864-94371f098ece","storage_class":"zyvor-rbd-prod","requested_storage_gi":1.0,"access_modes":["ReadWriteOnce"],"created_at":"2026-10-27T03:07:07+00:00"},{"name":"veyron-image-store","namespace":"veyron-system","status":"Bound","volume_name":"pvc-4c52f733-b95c-4294-a8ce-299d8f281441","storage_class":"zyvor-rbd-prod","requested_storage_gi":50.0,"access_modes":["ReadWriteOnce"],"created_at":"2026-11-04T06:48:54+00:00"},{"name":"zeus-os-data","namespace":"zeus-os","status":"Bound","volume_name":"pvc-d75f7216-d93a-4f30-bb60-c95a4668e640","storage_class":"zyvor-rbd-prod","requested_storage_gi":5.0,"access_modes":["ReadWriteOnce"],"created_at":"2026-11-07T06:06:15+00:00"}]"#)
    #expect(r.count == 3 && r[0].requestedGi == 1.0 && r[0].id == "rook-ceph/atlas-gateway-ceph-data")
}
@Test func decodesStorageVolumes() throws {
    let r = try dec([StorageVolume].self, #"[{"name":"pvc-4c52f733-b95c-4294-a8ce-299d8f281441","capacity_gi":50.0,"storage_class":"zyvor-rbd-prod","access_modes":["ReadWriteOnce"],"status":"Bound","claim":"veyron-system/veyron-image-store","reclaim_policy":"Delete","created_at":"2026-11-04T06:48:57+00:00"},{"name":"pvc-d75f7216-d93a-4f30-bb60-c95a4668e640","capacity_gi":5.0,"storage_class":"zyvor-rbd-prod","access_modes":["ReadWriteOnce"],"status":"Bound","claim":"zeus-os/zeus-os-data","reclaim_policy":"Delete","created_at":"2026-11-07T06:06:19+00:00"},{"name":"pvc-fbd16fce-f09f-42c1-b864-94371f098ece","capacity_gi":1.0,"storage_class":"zyvor-rbd-prod","access_modes":["ReadWriteOnce"],"status":"Bound","claim":"rook-ceph/atlas-gateway-ceph-data","reclaim_policy":"Delete","created_at":"2026-10-27T03:07:13+00:00"}]"#)
    #expect(r.count == 3 && r[0].capacityGi == 50)
}
@Test func decodesStorageOverview() throws {
    let o = try dec(StorageOverview.self, #"{"total_capacity_gi":56.0,"used_capacity_gi":56.0,"available_capacity_gi":0.0,"utilization_percent":100.0,"total_volumes":3,"bound_volumes":3,"available_volumes":0,"total_pvcs":3,"bound_pvcs":3,"pending_pvcs":0,"storage_classes":4}"#)
    #expect(o.totalGi == 56 && o.utilizationPercent == 100 && o.pendingPVCs == 0)
}
@Test func decodesImagesWithNestedVulnerabilities() throws {
    let r = try dec([ContainerImage].self, #"[{"id":"docker.io/library/veyron-operator:latest","repository":"docker.io/library/veyron-operator","tag":"latest","fullName":"docker.io/library/veyron-operator:latest","digest":"","sizeBytes":0,"createdAt":"","pulledAt":null,"scanStatus":"NotScanned","vulnerabilities":{"critical":0,"high":0,"medium":0,"low":0,"unknown":0},"pullCount":1,"os":"unknown","osVersion":"","arch":""}]"#)
    #expect(r[0].critical == 0 && r[0].scanStatus == "NotScanned" && r[0].sizeBytes == 0)
}
@Test func decodesDRPlanFromSpec() throws {
    let p = try dec([DRPlan].self, #"[{"id":"p1","name":"prod","description":"","plan_type":"failover","enabled":true,"primary_site":"a","secondary_site":"b","target_rpo_minutes":15,"target_rto_minutes":60,"current_rpo_minutes":null,"health_status":"unknown","last_tested":null,"protected_resources":[]}]"#)
    #expect(p[0].targetRPOMinutes == 15 && p[0].currentRPOMinutes == nil)
}
@Test func decodesVeleroFromSpec() throws {
    let b = try dec([VeleroBackup].self, #"[{"name":"b1","namespace":"velero","phase":"Completed","created_at":"x","completed_at":null,"included_namespaces":["a"],"total_items":3,"size_bytes":10}]"#)
    let r = try dec([VeleroRestore].self, #"[{"name":"r1","namespace":"velero","backup_name":"b1","phase":"Completed","errors":0,"warnings":1}]"#)
    #expect(b[0].id == "velero/b1" && r[0].warnings == 1)
}
@Test func decodesDataVolumeFromSpec() throws {
    let v = try dec([DataVolume].self, #"[{"name":"d","namespace":"default","source_type":"blank","size":"10Gi","phase":"Succeeded","progress":"100%","age":"1d"}]"#)
    #expect(v[0].id == "default/d")
}
@Test func restoreBodyUsesServerKeys() throws {
    let data = try JSONEncoder().encode(RestoreBackupBody(backupID: "b-1", newVMName: "copy"))
    let o = try JSONSerialization.jsonObject(with: data) as? [String: Any]
    #expect(o?["backup_id"] as? String == "b-1" && o?["new_vm_name"] as? String == "copy" && o?["target_namespace"] == nil)
}
