from typing import Any, Dict, Optional

from nebari.schema import Base
from _nebari.stages.base import NebariTerraformStage

class CertManagerSolverConfig(Base):
    type: Optional[str] = "cloudflare"

class CertManagerConfig(Base):
    name: Optional[str] = "cert-manager"
    namespace: Optional[str] = None
    email: Optional[str] = None
    certificates: Optional[list[str, Any]] = []
    issuers: Optional[list[str, Any]] = []
    values: Optional[dict[str, Any]] = {}

class InputSchema(Base):
    cert_manager: CertManagerConfig = CertManagerConfig()

class CertManagerStage(NebariTerraformStage):
    name = "cert-manager"
    priority = 100

    input_schema = InputSchema

    def input_vars(self, stage_outputs: Dict[str, Dict[str, Any]]):
        domain = stage_outputs["stages/04-kubernetes-ingress"]["domain"]
        zone = ".".join(domain.split(".")[-2:])
        chart_ns = self.config.cert_manager.namespace
        create_ns = True
        if chart_ns == None or chart_ns == "" or chart_ns == self.config.namespace:
            chart_ns = self.config.namespace
            create_ns = False

        return {
            "name": self.config.cert_manager.name,
            "domain": domain,
            "zone": zone,
            "create_chart_namespace": create_ns,
            "chart_namespace": chart_ns,
            "namespace": self.config.namespace,
            "certificates": self.config.cert_manager.certificates,
            "issuers": self.config.cert_manager.issuers,
            "overrides": self.config.cert_manager.values
        }
        