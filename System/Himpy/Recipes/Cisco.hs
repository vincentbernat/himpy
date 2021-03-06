module System.Himpy.Recipes.Cisco where
import System.Himpy.Recipes.Utils
import System.Himpy.Mib
import System.Himpy.Types
import System.Himpy.Logger
import Control.Concurrent.STM.TChan (TChan)
import qualified Data.Map as M

cisco_rcp :: TChan ([Metric]) -> TChan (String) -> HimpyHost -> IO ()
cisco_rcp chan logchan (Host host comm _) = do


  cpu_pct <- snmp_get_num host comm pfeCpuPercent
  sess_cnt <- snmp_get_num host comm pfeSessions
  sess_max <- snmp_get_num host comm pfeSessionMax
  psu1 <- snmp_get_num host comm pfePSU1
  psu2 <- snmp_get_num host comm pfePSU2

  let tuples = [("juniper.cpu",cpu_pct),
                ("juniper.sessions.count", sess_cnt),
                ("juniper.sessions.max", sess_max),
                ("juniper.sessions.pct", (sess_cnt / sess_max) * 100),
                ("juniper.psu1", psu1),
                ("juniper.psu2", psu2)]
  let mtrs = snmp_metrics host "" tuples

  log_info logchan $ "got snmp result: " ++ show (mtrs)
