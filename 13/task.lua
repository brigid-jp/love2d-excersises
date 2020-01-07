--[[

thread_pool

task()

task_package()
  header_task()
  download_task()

async_task()

check_task()

http_download_task

task
            C++       Scala     ES
  実行前                        pending
  実行中    deferred
  実行完了  ready     complete  settled
    成功              success   fulfilled
    失敗              failure   rejected

  ES promise
    resolved

  Lua coroutine
    running
    suspended
    normal
    dead

  status
    (pending)
    running
    success
    failure

  progress = { number, ... }

tasks { task, ... }
  header_task, download_task

cancel
update

if check then
  return
end

header
download
check
]]
