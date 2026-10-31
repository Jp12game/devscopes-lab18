const { S3Client, ListBucketsCommand, GetBucketTaggingCommand } = require('@aws-sdk/client-s3'); 

const { SNSClient, PublishCommand } = require('@aws-sdk/client-sns'); 

  

const REQUIRED_TAGS = ['CostCenter', 'Environment']; 

const REGION = process.env.AWS_REGION || 'us-east-1'; 

const s3Client = new S3Client({ region: REGION }); 

const snsClient = new SNSClient({ region: REGION }); 

  

exports.handler = async () => { 

  const { Buckets } = await s3Client.send(new ListBucketsCommand({})); 

  const nonCompliant = []; 

  

  for (const bucket of Buckets) { 

    let tags = []; 

    try { 

      const result = await s3Client.send(new GetBucketTaggingCommand({ Bucket: bucket.Name })); 

      tags = result.TagSet.map((t) => t.Key); 

    } catch (err) { 

      if (err.name !== 'NoSuchTagSet') throw err; 

    } 

  

    const missing = REQUIRED_TAGS.filter((t) => !tags.includes(t)); 

    if (missing.length > 0) { 

      nonCompliant.push({ bucket: bucket.Name, missing }); 

    } 

  } 

  

  const report = nonCompliant.length === 0 

    ? 'Todos los buckets de S3 cumplen con las etiquetas requeridas.' 

    : `${nonCompliant.length} bucket(s) sin etiquetas requeridas:\n` + 

      nonCompliant.map((b) => `- ${b.bucket}: falta ${b.missing.join(', ')}`).join('\n'); 

  

  console.log(report); 

  

  await snsClient.send(new PublishCommand({ 

    TopicArn: process.env.TOPIC_ARN, 

    Subject: 'Reporte de cumplimiento de etiquetas de costos', 

    Message: report, 

  })); 

  

  return { nonCompliantCount: nonCompliant.length }; 

}; 