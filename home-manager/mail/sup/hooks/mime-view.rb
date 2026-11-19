# filename has already been shellesacped
pid = Process.spawn("mimeopen", filename,
                    :out => '/dev/null',
                    :err => '/dev/null')

Process.detach pid

true
