class UserHoursAssignmentsQuery
  attr_accessor :initial_scope, :options

  def initialize(initial_scope: User.all, options: {})
    @initial_scope = initial_scope
    @options = options

    validate_options!
  end

  def call
    scope = initial_scope.where(users: { role: :user })
    scope = join_hours_count_query(scope, options[:service_id], options[:week])
    scope.select(['users.id as id',
                  'users.color as color',
                  'users.name as name',
                  'coalesce(hc.cnt, 0) as hours_count'])
  end

  private

  def join_hours_count_query(scope, service_id, week)
    scope if service_id.nil? || week.nil?
    scope.joins("LEFT JOIN (#{hours_count_query}) hc
                                                    ON hc.user_id = users.id
                                                    AND hc.service_week = #{week}
                                                    AND  hc.service_id = #{service_id}")
  end

  def hours_count_query
    <<-SQL.squish
      SELECT
        u.id AS user_id, sw.week AS service_week, s.id AS service_id, count(*) AS cnt
      FROM
        users u, services s, service_hours sh, service_days sd, service_weeks sw
      WHERE
        sh.designated_user_id = u.id
        AND sh.service_day_id = sd.id
        AND sd.service_week_id = sw.id
        AND sw.service_id = s.id
      GROUP BY
        u.id, sw.week, s.id
    SQL
  end

  def validate_options!
    if options[:service_id].nil? || (options[:service_id].present? && !Service.exists?(options[:service_id]))
      raise ArgumentError,
            "invalid service_id: #{options[:service_id]}"
    end
    raise ArgumentError, "invalid week: #{options[:week]}" if options[:week].nil?
  end
end
