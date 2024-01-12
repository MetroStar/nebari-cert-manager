from typing import Any, Dict, Optional

from nebari.schema import Base
from _nebari.stages.base import NebariTerraformStage

class CertManagerSolverConfig(Base):
    type: Optional[str] = "cloudflare"

class CertManagerConfig(Base):
    name: Optional[str] = "cert-manager"
    namespace: Optional[str] = None
    solver: CertManagerSolverConfig = CertManagerSolverConfig()
    values: Optional[Dict[str, Any]] = {}

class InputSchema(Base):
    cert_manager: CertManagerConfig = CertManagerConfig()

class CertManagerStage(NebariTerraformStage):
    name = "cert-manager"
    priority = 100

    input_schema = InputSchema

    def input_vars(self, stage_outputs: Dict[str, Dict[str, Any]]):
        domain = stage_outputs["stages/04-kubernetes-ingress"]["domain"]
        zone = domain.split(".")[-2:]
        chart_ns = self.config.cert_manager.namespace
        create_ns = True
        if chart_ns == None or chart_ns == "" or chart_ns == self.config.namespace:
            chart_ns = self.config.namespace
            create_ns = False

        return {
            "name": self.config.cert_manager.name,
            "domain": domain,
            "zone": zone,
            "create_namespace": create_ns,
            "namespace": chart_ns,
            "overrides": self.config.cert_manager.values,
            "solver_type": self.config.cert_manager.solver.type
        }
        